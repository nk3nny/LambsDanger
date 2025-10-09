#include "script_component.hpp"
/*
 * Author: nkenny
 * Group leadership initiates immediate reaction to contact
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: enemy <OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_contact;
 *
 * Public: No
*/
params [["_unit", objNull, [objNull]], ["_enemy", objNull, [objNull]]];

// only leader
if !((leader _unit) isEqualTo _unit || {_unit call EFUNC(main,isAlive)}) exitWith {false};

// identify enemy
if (isNull _enemy) then {
    private _enemies = _unit targets [true];
    if (_enemies isNotEqualTo []) exitWith {_enemy = _enemies select 0};
    _enemy = objNull
};

// no enemy -- minor pause
private _group = group _unit;
if (isNull _enemy || { (side _group) isEqualTo (side group _enemy) } ) exitWith {
    _group setVariable [QGVAR(contact), time + 10 + random 10];
    _group setFormDir random 360;
    false
};

// update contact state
_group setVariable [QGVAR(contact), time + 600];

// set group task
//_group setVariable [QGVAR(isExecutingTactic), true];
_group setVariable [QEGVAR(main,currentTactic), "Contact!", EGVAR(main,debug_functions)];

// change formation and attack state
_group enableAttack false;
_group setFormation (_group getVariable [QGVAR(dangerFormation), formation _unit]);
_group setFormDir (_unit getDir _enemy);

// call event system
[QGVAR(onContact), [_unit, _group, _enemy]] call EFUNC(main,eventCallback);

// gesture + callouts for larger units
private _stealth = (behaviour _unit) isEqualTo "STEALTH";
private _units = (units _unit) select {!isPlayer _x && {isNull objectParent _x}};
if (count _units > 2) then {
    // gesture
    [{_this call EFUNC(main,doGesture)}, [_unit, "gestureFreeze", true], 0.3] call CBA_fnc_waitAndExecute;

    // supporting unit
    private _unitCaller = _units select -1;

    // point
    [{_this call EFUNC(main,doGesture)}, [_unitCaller, "gesturePoint"], 0.3 + random 4] call CBA_fnc_waitAndExecute;

    // contact!
    [{_this call EFUNC(main,doCallout)}, [_unitCaller, ["Combat", "Stealth"] select _stealth, "contact"], 0.3 + random 4] call CBA_fnc_waitAndExecute;
};

// callout and share information
[
    {
        params ["_unit", "_enemy", "_stealth"];
        [_unit, _enemy, EGVAR(main,radioShout), true] call EFUNC(main,doShareInformation);
        [_unit, ["Combat", "Stealth"] select _stealth, "contact"] call EFUNC(main,doCallout);
    }, [_unit, _enemy, _stealth], 1 + random 4
] call CBA_fnc_waitAndExecute;

// units stealthy or indoor units stay inside
if (_stealth || {[_unit] call EFUNC(main,isIndoor)}) then {
    private _buildings = [leader _unit, 35, true, true] call EFUNC(main,findBuildings);
    _group setVariable [QEGVAR(main,groupMemory), _buildings, false];
};

// drop low
{
    if ((unitPos _x) isEqualTo "Auto") then {_x setUnitPosWeak "DOWN";};
} forEach _units;

// leader seeks cover
if (
    ((expectedDestination _unit) select 1) isEqualTo "DoNotPlan"
) then {
    private _cover = nearestTerrainObjects [ _unit, ["BUSH", "TREE", "SMALL TREE", "HOUSE", "ROCK", "WALL", "FENCE"], 35, false, true ];
    if (_cover isNotEqualTo []) then {
        _cover = selectRandom _cover;
        _unit doMove ( ( _cover getPos [1, _enemy getDir _cover]) );
    };
};

// set current task
_unit setVariable [QEGVAR(main,currentTarget), _enemy, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Contact!", EGVAR(main,debug_functions)];

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 CONTACT! %2 @ %3m", side _unit, groupId _group, round (_unit distance2D _enemy)] call EFUNC(main,debugLog);
    private _m = [_unit, "contact!", _unit call EFUNC(main,debugMarkerColor), "mil_warning"] call EFUNC(main,dotMarker);
    _m setMarkerSizeLocal [0.8, 0.8];
    [{{deleteMarker _x;true} count _this;}, [_m], 45] call CBA_fnc_waitAndExecute;
};

// end
true
