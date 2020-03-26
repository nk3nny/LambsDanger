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

// settings -- CHANGE IN SETTING. WILL BE DECREPITATED BY VERSION 2.1 -- line 25 to 30 changes variable to the proper one.
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
[QGVAR(OnAssess), [_unit, group _unit, _enemy]] call FUNC(eventCallback);

// leadership assessment
if !(_enemy isEqualTo []) then {

    // Enemy is in buildings or at lower position
    private _targets = _enemy findIf {_x isKindOf "Man" && { _x call FUNC(indoor) || {( getPosASL _x select 2 ) < ( (getPosASL _unit select 2) - 23) }}};
    if (_targets != -1 && {!GVAR(disableAIAutonomousManoeuvres)}) then {
        [_unit, 3, getPosATL (_enemy select _targets)] call FUNC(leaderMode);
    
        // gesture
        [_unit, ["gesturePoint"]] call FUNC(gesture);
    
    };

    // Enemy is Tank/Air?
    _targets = _enemy findIf {_x isKindOf "Air" || { _x isKindOf "Tank" && { _x distance2d _unit < 200 }}};
    if (_targets != -1 && {!GVAR(disableAIHideFromTanksAndAircraft)}) then {
        [_unit, 2, _enemy select _targets] call FUNC(leaderMode);

        // callout
        private _callout = if (isText (configFile >> "CfgVehicles" >> typeOf (_enemy select _targets) >> "nameSound")) then {
            getText (configFile >> "CfgVehicles" >> typeOf (_enemy select _targets) >> "nameSound")
        } else {
            "KeepFocused"
        };
        [_unit, behaviour _unit, _callout, 125] call FUNC(doCallout);
    };

    // Artillery
    _targets = _enemy select {_x distance _unit > 200};
    if !(_targets isEqualTo [] || {([EGVAR(main,SideArtilleryHash), side _unit] call CBA_fnc_hashGet) isEqualTo []}) then {
        [_unit, 6, (_unit getHideFrom (_targets select 0))] call FUNC(leaderMode);
    };

    // communicate <-- possible remove?
    [_unit, selectRandom _enemy] call FUNC(shareInformation);

} else {

    // callout
    [_unit, "combat", selectRandom ["KeepFocused ", "StayAlert"], 100] call FUNC(doCallout);

};

// binoculars if appropriate!
if (RND(0.2) && {(_unit distance _pos > 150) && {!(binocular _unit isEqualTo "")}}) then {
    _unit selectWeapon (binocular _unit);
    _unit doWatch _pos;
};

// update formation direction
_unit setFormDir (_unit getDir _pos);

// man empty statics?
private _weapons = nearestObjects [_unit, ["StaticWeapon"], 60, true];
_weapons = _weapons select {locked _x != 2 && {(_x emptyPositions "Gunner") > 0}};

// give orders
private _units = units _unit select { _x call FUNC(isAlive) && {unitReady _x} && { _x distance2d _unit < 100 } && { isNull objectParent _x } && { !isPlayer _x }};

// isolated leader
if (count _units < 2) then {
    _unit doFollow selectRandom _units;
};

if !((_weapons isEqualTo []) || (_units isEqualTo [])) then { // De Morgan's laws FTW

    // pick a random unit
    _units = selectRandom _units;
    _weapons = selectRandom _weapons;

    // asign no target
    _units doWatch ObjNull;

    // order to man the vehicle
    _units assignAsGunner _weapons;
    [_units] orderGetIn true;
    (group _unit) addVehicle _weapons;
};

// set current task -- moved here so it is not interfered by things happening above
_unit setVariable [QGVAR(currentTarget), objNull];
_unit setVariable [QGVAR(currentTask), "Leader Assess"];

// end
true
