#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit moves to check a body
 *
 * Arguments:
 * 0: unit doing the checking <OBJECT>
 * 1: position to check <ARRAY>
 * 2: Radius to check for bodies <NUMBER>, default 8 meters
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob, getpos angryJoe, 10] call lambs_danger_fnc_doCheckBody;
 *
 * Public: No
*/
params ["_unit", ["_pos", []], ["_radius", 8]];

// check
if (_pos isEqualTo []) then {_pos = getPosASL _unit;};

// find body + rearm
private _bodies = allDeadMen findIf { (_x distance2D _pos) < _radius };
if (_bodies isEqualTo -1) exitWith {false};

// body
private _body = (allDeadMen select _bodies);

// execute
_unit setUnitPosWeak "MIDDLE";
_unit doMove getPosATL _body;
_unit lookAt _body;
_unit setVariable [QGVAR(forceMove), true];
[
    {
        // condition
        params ["_unit", "_body"];
        (_unit distance _body < 0.7) || {!(_unit call EFUNC(main,isAlive))}
    },
    {
        // on near body
        params ["_unit", "_body"];
        if (_unit call EFUNC(main,isAlive)) then {
            [QGVAR(OnCheckBody), [_unit, group _unit, _body]] call EFUNC(main,eventCallback);
            _unit action ["rearm", _body];
            _unit doFollow leader _unit;
            _unit setVariable [QGVAR(forceMove), nil];
        };
    },
    [_unit, _body], 8,
    {
        // on timeout
        params ["_unit"];
        if (_unit call EFUNC(main,isAlive)) then {
            _unit doFollow leader _unit;
            _unit setVariable [QGVAR(forceMove), nil];
        };
    }
] call CBA_fnc_waitUntilAndExecute;

// set variable
_unit setVariable [QGVAR(currentTarget), _pos, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Checking bodies", EGVAR(main,debug_functions)];

// end
true