#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit performs a mutual assault or suppressive fire on a location listed in the group "memory"
 *
 * Arguments:
 * 0: Unit assaulting <OBJECT>
 * 1: Group memory <ARRAY>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_danger_fnc_assaultMemory;
 *
 * Public: No
*/
params ["_unit", ["_groupMemory", []]];

// check it
if (_groupMemory isEqualTo []) then {
    _groupMemory = (group _unit) getVariable [QGVAR(groupMemory)];
};

// sort it
_groupMemory = _groupMemory select {_unit distance2D _x < 200 && {_unit distance2D _x > 3}};
if (_groupMemory isEqualTo []) exitWith {_unit doFollow leader _unit; false};

// check
private _pos = _groupMemory select 0;
private _distance = _unit distance2D _pos;
if (_pos isEqualType objNull) then {_pos = getPosATL _pos;};

// CQB or suppress
if (RND(0.9) || {_distance < (GVAR(cqbRange) * 1.1)}) then {

    // CQB movement mode
    _unit setUnitPosWeak selectRandom ["UP", "UP", "MIDDLE"];
    _unit forceSpeed ([_unit, _pos] call FUNC(assaultSpeed));

    // execute CQB move
    _unit doMove _pos;
    _unit setDestination [_pos, "FORMATION PLANNED", true];

    // variables
    _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Assault (Sympathetic)", EGVAR(main,debug_functions)];

    // debug
    if (EGVAR(main,debug_functions)) then {
        ["%1 assaulting (sympathetic) (%2 @ %3m)", side _unit, name _unit, round (_unit distance _pos)] call EFUNC(main,debugLog);
        private _sphere = createSimpleObject ["Sign_Sphere10cm_F", AGLtoASL _pos, true];
        _sphere setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
        [{deleteVehicle _this}, _sphere, 10] call CBA_fnc_waitAndExecute;
    };

} else {

    // execute suppression
    _unit setUnitPosWeak "MIDDLE";
    _unit forceSpeed ([1, -1] select (getSuppression _unit > 0.8));
    [_unit, (AGLToASL _pos) vectorAdd [0, 0, 1.2], true] call FUNC(doSuppress);
    _unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
    _unit setVariable [QGVAR(currentTask), "Suppress (Sympathetic)!", EGVAR(main,debug_functions)];

};

// update variable
if (RND(0.95) || {_distance < 5}) then {_groupMemory deleteAt 0;};
(group _unit) setVariable [QGVAR(groupMemory), _groupMemory, false];

// end
true