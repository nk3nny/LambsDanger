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
#define TACTICS_HIDE 0
#define TACTICS_FLANK 1
#define TACTICS_GARRISON 2
#define TACTICS_ASSAULT 3
#define TACTICS_SUPPRESS 4

params [["_unit", objNull, [objNull]], ["_delay", 45]];

// check if group AI disabled
private _group = group _unit;
if (_group getVariable [QGVAR(disableGroupAI), false]) exitWith {false};

// set variable
_group setVariable [QGVAR(isExecutingTactic), true];
_group setVariable [QGVAR(contact), time + 600];

// set current task
_unit setVariable [QGVAR(currentTarget), objNull, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Tactics Assess", EGVAR(main,debug_functions)];

// gather data
private _enemies = (_unit targets [true, 600]) select {_unit knowsAbout _x > 1};
private _plan = [];

// leader assess EH
[QGVAR(OnAssess), [_unit, _group, _enemies]] call EFUNC(main,eventCallback);

// sort plans
private _pos = [];
if !(_enemies isEqualTo []) then {

    // communicate
    [_unit, selectRandom _enemies] call FUNC(shareInformation);

    // vehicle response
    private _tankTarget = _enemies findIf {
        _x isKindOf "Tank"
        && {_unit distance2D _x < 350}
        && {!(terrainIntersectASL [eyePos _unit, eyePos _x])};
    };
    if (_tankTarget != -1 && {!GVAR(disableAIHideFromTanksAndAircraft)}) then {
        _plan pushBack TACTICS_HIDE;
        _pos = _unit getHideFrom (_enemies select _tankTarget);

        // anti-vehicle callout
        private _callout = if (isText (configFile >> "CfgVehicles" >> typeOf (_enemies select _tankTarget) >> "nameSound")) then {
            getText (configFile >> "CfgVehicles" >> typeOf (_enemies select _tankTarget) >> "nameSound")
        } else {
            "KeepFocused"
        };
        [_unit, behaviour _unit, _callout, 125] call EFUNC(main,doCallout);
    };

    // anti-infantry tactics
    _enemies = _enemies select {_x isKindOf "Man"};
    private _inside = _unit call EFUNC(main,isIndoor);

    // Check for artillery ~ NB: support is far quicker now! and only targets infantry
    private _artilleryTarget = _enemies findIf {
        _x distance2D _unit > 200
    };
    if (_artilleryTarget != -1 && { GVAR(Loaded_WP) && {[side _unit] call EFUNC(WP,sideHasArtillery)} }) then {
        [_unit, _unit getHideFrom (_enemies select _artilleryTarget)] call FUNC(leaderArtillery);   // possibly add delay? ~ nkenny
    };

    // no manoeuvres -- exit
    if (GVAR(disableAIAutonomousManoeuvres)) exitWith {_plan = [];};

    // enemies within X meters of leader
    private _target = _enemies findIf {
        _unit distance2D _x < GVAR(cqbRange)
        && {_inside || {_x call EFUNC(main,isIndoor)}}
    };
    if (_target != -1) exitWith {
        _plan append [TACTICS_GARRISON, TACTICS_GARRISON, TACTICS_ASSAULT];
        _pos = [_unit getHideFrom (_enemies select _target), getPosASL _unit] select _inside;
    };

    // inside? stay safe
    if (_inside) exitWith {_plan = [];};

    // enemies far away or above!
    _target = _enemies findIf {
        _unit distance2D _x > 350
        || {(getPosASL _x select 2 ) > ((getPosASL _unit select 2) + 15)}
    };
    if (_target != -1) exitWith {
        _plan append [TACTICS_SUPPRESS, TACTICS_FLANK];
        if ((combatMode _unit) isEqualTo "RED" || {speedMode _unit isEqualTo "FULL"}) then {_plan pushBack TACTICS_ASSAULT;};
        _pos = _unit getHideFrom (_enemies select _target);
    };
    // enemies away from buildings or below
    _target = _enemies findIf {
        _unit distance2D _x < 220
        && {
            ( getPosASL _x select 2 ) < ( (getPosASL _unit select 2) - 10)
            || { ([_x, GVAR(cqbRange) * 0.55] call EFUNC(main,findBuildings)) isEqualTo []}
        };
    };
    if (_target != -1) exitWith {
        _plan pushBack TACTICS_FLANK;
        if ((combatMode _unit) isEqualTo "RED" || {speedMode _unit isEqualTo "FULL"}) then {_plan pushBack TACTICS_ASSAULT;};
        _pos = _unit getHideFrom (_enemies select _target);

        // mark enemy position for sympathetic fire
        _group setVariable [QGVAR(CQB_pos), (nearestTerrainObjects [_pos, [], 5, false, true]) apply {getPos _x}];
    };

    // enemy inside buildings or fortified
    _target = _enemies findIf {
        _x call EFUNC(main,isIndoor)
        || {!((nearestObjects [_x, ["Strategic", "StaticWeapon"], 2, true]) isEqualTo [])}
    };
    if (_target != -1) exitWith {

        // basic plan
        _plan append [TACTICS_FLANK, TACTICS_FLANK];
        _pos = _unit getHideFrom (_enemies select _target);

        // combatmode
        private _combatMode = combatMode _unit;
        if (_combatMode isEqualTo "RED") then {_plan pushBack TACTICS_ASSAULT;};
        if (_combatMode in ["YELLOW", "WHITE"]) then {_plan pushBack TACTICS_SUPPRESS;};

        // visibility / distance / no cover
        if !(terrainIntersectASL [eyePos _unit, eyePos (_enemies select _target)]) then {_plan pushBack TACTICS_SUPPRESS;};
        if (_unit distance2D _pos < 120) then {_plan pushBack TACTICS_ASSAULT;};
        if ((nearestTerrainObjects [ _unit, ["BUSH", "TREE", "HOUSE", "HIDE"], 4, false, true ]) isEqualTo []) then {_plan pushBack TACTICS_FLANK;};

        // conceal movement
        [_unit, _pos] call EFUNC(main,doSmoke);
    };
};

// find units
private _units = [_unit] call EFUNC(main,findReadyUnits);

// deploy flares
if (!(GVAR(disableAutonomousFlares)) && {_unit call EFUNC(main,isNight)}) then {
    _units = [_units] call EFUNC(main,doUGL);
};

// man empty static weapons
if !(GVAR(disableAIFindStaticWeapons)) then {
    _units = [_units, _unit] call FUNC(leaderStaticFind);
};

// no plan ~ exit with no executable plan
if (_plan isEqualTo [] || {_pos isEqualTo []} || {count units _unit < 3}) exitWith {

    // callout
    if (count units _unit > 2) then {[_unit, "combat", selectRandom ["KeepFocused ", "StayAlert"], 100] call EFUNC(main,doCallout);};

    // has taken casualties: hide
    private _alive = units _unit findIf {!(_x call EFUNC(main,isAlive))};
    if (_alive != -1) then {
        [{_this call FUNC(tacticsHide)}, [_unit, _unit getPos [100, random 360], false], random 3] call CBA_fnc_waitAndExecute;
    };

    // check new random direction if no enemy found!
    if (isNull (_unit findNearestEnemy _unit)) then {
        _group setFormDir (random 360);
    };

    // recheck in a moment
    [
        {
            params ["_group"];
            if (!isNull _group) then {
                _group setVariable [QGVAR(isExecutingTactic), nil];
                _group setVariable [QGVAR(tacticsTask), nil];
            };
        },
        _group,
        _delay + random 5
    ] call CBA_fnc_waitAndExecute;
    false
};

// update formation direction ~ enemy pos known!
_unit setFormDir (_unit getDir _pos);

// binoculars if appropriate!
if (RND(0.2) && {(_unit distance2D _pos > 150) && {!(binocular _unit isEqualTo "")}}) then {
    _unit selectWeapon (binocular _unit);
    _unit doWatch _pos;
};

// deploy static weapons
if !(GVAR(disableAIDeployStaticWeapons)) then {
    _units = [_units, _pos] call FUNC(leaderStaticDeploy);
};

// enact plan
_plan = selectRandom _plan;
switch (_plan) do {
    case TACTICS_FLANK: {
        // flank
        [{_this call FUNC(tacticsFlank)}, [_unit, _pos], 30] call CBA_fnc_waitAndExecute;
        if !(_units isEqualTo []) then {[_units] call EFUNC(main,doSmoke);};
    };
    case TACTICS_GARRISON: {
        // garrison
        [{_this call FUNC(tacticsGarrison)}, [_unit, _pos], 10 + random 6] call CBA_fnc_waitAndExecute;
    };
    case TACTICS_ASSAULT: {
        // rush ~ assault
        [{_this call FUNC(tacticsAssault)}, [_unit, _pos], 30] call CBA_fnc_waitAndExecute;
        if !(_units isEqualTo []) then {[_units] call EFUNC(main,doSmoke);};
    };
    case TACTICS_SUPPRESS: {
        // suppress
        [{_this call FUNC(tacticsSuppress)}, [_unit, _pos], 6 + random 4] call CBA_fnc_waitAndExecute;
    };
    default {
        // hide from armor
        [{_this call FUNC(tacticsHide)}, [_unit, _pos, true], random 3] call CBA_fnc_waitAndExecute;
    };
};

// end
true
