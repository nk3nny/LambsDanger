#include "script_component.hpp"
/*
 * Author: nkenny
 * Group leader assesses situation and calls manoeuvres or support assets as necessary
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: Time until tactics state ends <NUMBER>, 60 seconds default
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob] call lambs_danger_fnc_tacticsAssess;
 *
 * Public: No
*/
params [["_unit", objNull, [objNull]], ["_Zzz", 30]];

// check if group AI disabled
if ((group _unit) getVariable [QGVAR(disableGroupAI), false]) exitWith {false};

// set variable
group _unit setVariable [QGVAR(tactics), true];
group _unit setVariable [QGVAR(contact), time + 300];

// gather data
private _enemies = (_unit targets [true, 600, [], 0]) select {_unit knowsAbout _x > 1};
private _plan = [];

// sort plans
private _target = [];
if !(_enemies isEqualTo []) then {

    // communicate
    [_unit, selectRandom _enemies] call FUNC(shareInformation);

    // vehicle response
    private _tank = _enemies findIf {
        _x isKindOf "Tank"
        && {_unit distance2D _x < 350}
        && {!(terrainIntersectASL [eyePos _unit, eyePos _x])};
    };
    if (_tank != -1) then {
        _plan pushBack 0; // hide!
        _target = _unit getHideFrom (_enemies select _tank);
    };

    // anti-infantry tactics
    _enemies = _enemies select {_x isKindOf "Man"};
    private _inside = _unit call EFUNC(main,isIndoor);

    // enemies within X meters of leader
    private _targets = _enemies findIf {
        _unit distance2D _x < GVAR(CQB_range)
        && {_inside || {_x call EFUNC(main,isIndoor)}}
    };
    if (_targets != -1 && {!GVAR(disableAIAutonomousManoeuvres)}) exitWith {
        _plan append [2, 2, 3];    // garrison, garrison, rush
        _target = [getpos (_enemies select _targets), getPos _unit] select _inside;
    };
    
    // inside? stay safe
    if (_inside) exitWith {_plan = [];};

    // enemies far away or above!
    private _targets = _enemies findIf {
        _unit distance2D _x > 300
        && {(getPosASL _x select 2 ) < ((getPosASL _unit select 2) + 15)}
    };
    if (_targets != -1) exitWith {
        _plan pushBack 4;   // suppress
        _target = getpos (_enemies select _targets);
    };
    // enemies away from buildings or below
    private _targets = _enemies findIf {
        _unit distance2D _x < 220
        && {_unit distance2D _x > GVAR(CQB_range)}
        && {
            ( getPosASL _x select 2 ) < ( (getPosASL _unit select 2) - 10)
            || { ([_x, GVAR(CQB_range) * 0.55] call liteDanger_fnc_findBuildings) isEqualTo []}
        };
    };
    if (_targets != -1) exitWith {
        _plan pushBack 1;   // flank
        _target = getpos (_enemies select _targets);
    };

    // enemy inside buildings or fortified
    private _targets = _enemies findIf {
        _x call EFUNC(main,isIndoor)
        || {!((nearestObjects [_x, ["Strategic", "StaticWeapon"], 2, true]) isEqualTo [])}
    };
    if (_targets != -1 && {!GVAR(disableAIAutonomousManoeuvres)}) exitWith {
        _plan append [1, 4];    // flank, suppress      // make smarter with examples from existing code from previous version! - nkenny
        _target = getpos (_enemies select _targets);
        [_unit, _target] call EFUNC(main,doSmoke);
    };

};

// no plan ~exit with no executable plan
if (_plan isEqualTo [] || {_target isEqualTo []} || {count units _unit < 2}) exitWith {
    [
        {
            params ["_group"];
            if (!isNull _group) then {
                _group setVariable [QGVAR(tactics), nil];
            };
        },
        group _unit,
        _Zzz
    ] call CBA_fnc_waitAndExecute;
    false
};

// group units
private _units = [_unit] call EFUNC(main,findReadyUnits);

// binoculars if appropriate!
if (RND(0.2) && {(_unit distance _target > 150) && {!(binocular _unit isEqualTo "")}}) then {
    _unit selectWeapon (binocular _unit);
    _unit doWatch _target;
};

// find units
private _units = [_unit] call EFUNC(main,findReadyUnits);

// deploy flares
if (!(GVAR(disableAutonomousFlares)) && {_unit call EFUNC(main,isNight)}) then {
    _units = [_units] call EFUNC(main,doUGL);
};

// deploy static weapons ~ also returns available units
if !(GVAR(disableAIDeployStaticWeapons)) then {
    _units = [_units, _target] call FUNC(leaderStaticDeploy);
};

// man empty static weapons
if !(GVAR(disableAIFindStaticWeapons)) then {
    _units = [_units, _unit] call FUNC(leaderStaticFind);
};

// enact plan
_plan = selectRandom _plan;
switch (_plan) do {
    case 1: {
        // flank
        [FUNC(tacticsFlank), [_unit, _target], 30] call CBA_fnc_waitAndExecute;
        if !(_units isEqualTo []) then {[_units] call EFUNC(main,doSmoke);};
    };
    case 2: {
        // garrison
        [FUNC(tacticsGarrison), [_unit, _target], 12 + random 6] call CBA_fnc_waitAndExecute;
    };
    case 3: {
        // rush ~ assault
        [FUNC(tacticsAssault), [_unit, _target], 30] call CBA_fnc_waitAndExecute;
        if !(_units isEqualTo []) then {[_units] call EFUNC(main,doSmoke);};
    };
    case 4: {
        // suppress
        [FUNC(tacticsSuppress), [_unit, _target], 6 + random 4] call CBA_fnc_waitAndExecute;
    };
    default {
        // hide from armor
        [FUNC(tacticsHide), [_unit, _target, true], random 3] call CBA_fnc_waitAndExecute;
    };
};

// set current task
_unit setVariable [QGVAR(currentTarget), objNull, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Tactics Assess", EGVAR(main,debug_functions)];


// end
true