#include "script_component.hpp"
// Check Body
// version 1.41
// by nkenny

// init
params ["_unit", "_pos", ["_range", 10]];

// check if stopped
if (stopped _unit || {!(attackEnabled _unit)}) exitWith {false};

// if too far away
if (_unit distance _pos > GVAR(CQB_range)) exitWith {false};

// half chance-- indoors
if (_unit call FUNC(indoor) && {random 1 > 0.5}) exitWith {false};

// find body
private _body = allDeadMen select {_x distance _pos < _range};
_body = _body select {!(_x getVariable [QGVAR(isChecked), false])};

// ready
doStop _this;

// Not checked? Move in close
if (count _body > 0) exitWith {
    // one body
    _body = _body select 0;

    _unit setVariable [QGVAR(currentTarget), _body];
    _unit setVariable [QGVAR(currentTask), "Check Body"];

    // do it
    private _bodyPos = getPosATL _body;
    _unit doMove _bodyPos;
    [
        {
            params ["_unit", "_bodyPos", "_time"];
            ((_unit distance _bodyPos) < 0.6) || {_time < time} || {!alive _unit}
        },
        {
            params ["_unit", "", "", "_body"];
            if (alive _unit && {!isNil str _body} && {_unit distance _pos < 0.6}) then {
                _unit action ["rearm", _body];
                _unit doFollow leader group _unit;
            };
        },
        [_unit, _bodyPos, time + 20, _body]
    ] call CBA_fnc_waitUntilAndExecute;

    // update variable
    _body setVariable [QGVAR(isChecked), true, true];

    // debug
    if (GVAR(debug_functions)) then {systemchat format ["%1 checking body (%2 %3m)", side _unit, name _unit, round (_unit distance _body)];};

    // end
    true
};

// checked? Move in close
_unit doMove (_pos getPos [2 + random 10, random 360]);

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 checking body area (%2m)", side _unit, round (_unit distance _pos)];};

// end
true
