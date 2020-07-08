#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader makes an assessment of current situation adding new tactics to group list if needed
 *
 * Arguments:
 * 0: Group leader making assessment <OBJECT>
 * 1: Position of danger, default none <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, getPos angryJoe] call lambs_danger_fnc_leaderAssess;
 *
 * Public: No
*/
params ["_unit", ["_pos", []]];

// get pos
if (_pos isEqualTo []) then {
    _pos = getPos _unit;
};

// settings -- CHANGE IN SETTING. WILL BE DECREPITATED BY VERSION 2.5 -- line 25 to 30 changes variable to the proper one.
private _mode = toLower ((group _unit) getVariable [QGVAR(dangerAI), ""]);
if (_mode isEqualTo "disabled") then {
    (group _unit) setVariable [QGVAR(disableGroupAI), true];
    (group _unit) setVariable [QGVAR(dangerAI), nil];
};
// ------------------------------------------------------------------

// check if group AI disabled
if ((group _unit) getVariable [QGVAR(disableGroupAI), false]) exitWith {false};

// AI profile stuff below
// AI profiles not yet implemented -- nkenny 15/02/2020

// enemy
private _enemy = _unit targets [true, 600, [], 0, _pos];

// update minimum delay
[_unit, 99, 66] call FUNC(leaderModeUpdate);

// leader assess EH
[QGVAR(OnAssess), [_unit, group _unit, _enemy]] call EFUNC(main,eventCallback);

// leadership assessment
if !(_enemy isEqualTo []) then {

    // Enemy is in buildings or at lower position or near bunker or static weapon
    private _targets = _enemy findIf {
        _x isKindOf "Man" && {
            _x call EFUNC(main,isIndoor)
            || {( getPosASL _x select 2 ) < ( (getPosASL _unit select 2) - 23) }
            || {!((nearestObjects [_x, ["Strategic", "StaticWeapon"], 2, true]) isEqualTo [])}
        }
    };
    if (_targets != -1 && {!GVAR(disableAIAutonomousManoeuvres)}) then {

        // select type
        private _target = _enemy select _targets;
        private _type = [3, 3];

        /*
        Types
            3 Flanking Manoeuvre
            4 Assault
            5 Group Suppressive fire
        */

        // combatmode
        if (combatMode _unit isEqualTo "RED") then {_type pushBack 4;};
        if (combatMode _unit in ["YELLOW", "WHITE"]) then {_type pushBack 5;};

        // visibility / distance / no cover
        if !(terrainIntersectASL [eyepos _unit, eyepos _target]) then {_type pushBack 5;};
        if (_unit distance2D _target < 120) then {_type pushBack 4;};
        if ((nearestTerrainObjects [ _unit, ["BUSH", "TREE", "HOUSE", "HIDE"], 4, false, true ]) isEqualTo []) then {_type pushBack 3;};  // could be retreat in the future! - nkenny

        // enable selection
        _type = selectRandom _type;
        [_unit, _type, getPosATL _target] call FUNC(leaderMode);

    };

    // Enemy is Tank/Air?
    _targets = _enemy findIf { _x isKindOf "Air" || { _x isKindOf "Tank" && { _x distance2D _unit < 200 }}};
    if (_targets != -1 && {!GVAR(disableAIHideFromTanksAndAircraft)}) then {

        [_unit, 2, _enemy select _targets] call FUNC(leaderMode);

        // callout
        private _callout = if (isText (configFile >> "CfgVehicles" >> typeOf (_enemy select _targets) >> "nameSound")) then {
            getText (configFile >> "CfgVehicles" >> typeOf (_enemy select _targets) >> "nameSound")
        } else {
            "KeepFocused"
        };
        [_unit, behaviour _unit, _callout, 125] call EFUNC(main,doCallout);
    };

    // Artillery
    _targets = _enemy findIf { _x distance2D _unit > 200 && { isTouchingGround (vehicle _x) }};
    if  (_targets != -1 && { GVAR(Loaded_WP) && {[side _unit] call EFUNC(WP,sideHasArtillery)} }) then {

        [_unit, 6, (_unit getHideFrom (_enemy select _targets))] call FUNC(leaderMode);

    };

    // communicate
    [_unit, selectRandom _enemy] call FUNC(shareInformation);

} else {

    // callout
    [_unit, "combat", selectRandom ["KeepFocused ", "StayAlert"], 100] call EFUNC(main,doCallout);

};

// update formation direction
_unit setFormDir (_unit getDir _pos);

// move
_unit forceSpeed 0;

// binoculars if appropriate!
if (RND(0.2) && {(_unit distance _pos > 150) && {!(binocular _unit isEqualTo "")}}) then {
    _unit selectWeapon (binocular _unit);
    _unit doWatch _pos;
};

// find units
private _units = [_unit] call EFUNC(main,findReadyUnits);

// deploy flares
if (!(GVAR(disableAutonomousFlares)) && {_unit call EFUNC(main,isNight)}) then {
    _units = [_units] call EFUNC(main,doUGL);
};

// deploy static weapons ~ also returns available units
if !(GVAR(disableAIDeployStaticWeapons)) then {
    _units = [_units, _pos] call FUNC(leaderStaticDeploy);
};

// man empty static weapons
if !(GVAR(disableAIFindStaticWeapons)) then {
    _units = [_units, _unit] call FUNC(leaderStaticFind);
};

// set current task
_unit setVariable [QGVAR(currentTarget), objNull, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Leader Assess", EGVAR(main,debug_functions)];

// end
true
