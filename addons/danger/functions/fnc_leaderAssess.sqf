#include "script_component.hpp"
// Leader Assesses situation
// version 1.41
//by nkenny

// init
params ["_unit",["_pos",[]],"_enemy","_targets","_units","_weapons"];

// get pos
if (_pos isEqualTo []) then {
    _pos = getPos _unit;
};

// settings
private _mode = toLower (group _unit getVariable ["dangerAI","enabled"]);

// check mode
if (_mode isEqualTo "disabled") exitWith {false};

// enemy
private ["_enemy","_targets","_units","_weapons"];
_enemy = _unit targets [true,600,[],0,_pos];

_unit setVariable [QGVAR(currentTarget), objNull];
_unit setVariable [QGVAR(currentTask), "Leader Assess"];

// update minimum delay
[_unit,99,30] call FUNC(leaderModeUpdate);

// leadership assessment
if (count _enemy > 0) then {

    // Enemy is lower than ours
    _targets = _enemy select {(getposASL _x select 2) < ((getposASL _unit select 2) - 21)};
    if (count _targets > 0) then {
        _unit setVariable [QGVAR(currentTarget), _targets select 0];
        [_unit,3,(_unit getHideFrom (_targets select 0))] call FUNC(leaderMode);
    };

    // Enemy is Tank/Air?
    _targets = _enemy select {_x isKindOf "Air" || {_x isKindOf "Tank" && {_x distance2d _unit < 400}}};
    if (count _targets > 0) then {
        [_unit,2,_targets select 0] call FUNC(leaderMode);
    };

    // Artillery
    _targets = _enemy select {_x distance _unit > 250};
    if (count _targets > 0 && {count (missionNameSpace getVariable ["lambs_artillery_" + str (side _unit),[]]) > 0}) then {
        [_unit,6,(_unit getHideFrom (_targets select 0))] call FUNC(leaderMode);
    };

    // communicate <-- possible remove?
    [_unit,selectRandom _enemy] call FUNC(shareInformation);

};

// Check nearby houses?
if (random 1 > 0.4 && {_unit distance (nearestBuilding _pos) < 25}) then {
        [_unit,4,_pos] call FUNC(leaderMode);
};

// binoculars if appropriate!
if ((_unit distance _pos > 150) && {!(binocular _unit isEqualTo "") && {random 1 > 0.2}}) then {
    _unit selectWeapon (binocular _unit);
    _unit doWatch _pos;
};

// man empty statics?
_weapons = nearestobjects [_pos,["StaticWeapon"],60,true];
_weapons = _weapons select {locked _x != 2 && {(_x emptyPositions "Gunner") > 0}};

// give orders
_units = units group _unit select {unitReady _x && {_x distance2d _pos < 70}};

if (count _weapons > 0 && {count _units > 0}) then {
    _units = selectRandom _units;
    _unit doWatch ObjNull;
    _units assignAsGunner (selectRandom _weapons);
    [_units] orderGetIn true;
};

// end
true
