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
 * [bob, getpos angryJoe] call lambs_danger_fnc_leaderAssess;
 *
 * Public: No
*/
params ["_unit", ["_pos", []]];

// get pos
if (_pos isEqualTo []) then {
    _pos = getPos _unit;
};

// settings
private _mode = toLower ((group _unit) getVariable [QGVAR(dangerAI), "enabled"]);

// check mode
if (_mode isEqualTo "disabled") exitWith {false};

// enemy
private _enemy = _unit targets [true, 600, [], 0, _pos];

// update minimum delay
[_unit, 99, 66] call FUNC(leaderModeUpdate);

// leadership assessment
if !(_enemy isEqualTo []) then {

    // Enemy is in buildings or at lower position
    private _targets = _enemy findIf {_x isKindOf "Man" && { _x call FUNC(indoor) || {( getposASL _x select 2 ) < ( (getposASL _unit select 2) - 23) }}};
    if (_targets != -1) then {
        [_unit, 3, getposATL (_enemy select _targets)] call FUNC(leaderMode);
    };

    // Enemy is Tank/Air?
    _targets = _enemy findIf {_x isKindOf "Air" || { _x isKindOf "Tank" && { _x distance2d _unit < 400 }}};
    if (_targets != -1) then {
        [_unit, 2, _enemy select _targets] call FUNC(leaderMode);
    };

    // Artillery
    _targets = _enemy select {_x distance _unit > 200};
    if !(_targets isEqualTo [] || {(( missionNameSpace getVariable [QGVAR(artillery_) + str (side _unit), []]) isEqualTo [])}) then {
        [_unit, 6, (_unit getHideFrom (_targets select 0))] call FUNC(leaderMode);
    };

    // communicate <-- possible remove?
    [_unit, selectRandom _enemy] call FUNC(shareInformation);

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
private _units = units _unit select {unitReady _x && { _x distance2d _unit < 100 } && { isnull objectParent _x } && { !isPlayer _x }};

// isolated leader
if (count _units < 2) then {
    _unit doFollow selectRandom units _unit;
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
