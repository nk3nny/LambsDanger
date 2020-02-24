#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit moves to check a dead body within given range
 *
 * Arguments:
 * 0: Unit assault cover <OBJECT>
 * 1: Position of dead body <ARRAY>
 * 2: Range to find bodies, default 10 <NUMBER>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, getpos angryJoe, 10] call lambs_danger_fnc_checkBody;
 *
 * Public: No
*/
params ["_unit", "_pos", ["_range", 10]];

// check if stopped or busy
if (
    stopped _unit
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
    || {!(attackEnabled _unit)}
    || {isplayer (leader _unit)}
    || {currentCommand _unit in ["GET IN", "ACTION", "HEAL"]}
) exitWith {false};

// if too far away
if (_unit distance _pos > GVAR(CQB_range)) exitWith {false};

// half chance-- indoors
if (RND(0.5) && { _unit call FUNC(indoor) }) exitWith {false};

// find body
private _body = allDeadMen select { (_x distance _pos) < _range };
_body = _body select {!(_x getVariable [QGVAR(isChecked), false])};

// ready
doStop _unit;

// Not checked? Move in close
if !(_body isEqualTo []) exitWith {
    // one body
    _body = selectRandom _body;

    _unit setVariable [QGVAR(currentTarget), _body];
    _unit setVariable [QGVAR(currentTask), "Check Body"];

    // do it
    private _bodyPos = getPosATL _body;
    _unit doMove _bodyPos;
    [
        {
            params ["_unit", "_time", "_body"];
            ((_unit distance _body) < 0.7) || {_time < time} || {!alive _unit}
        },
        {
            params ["_unit", "", "_body"];
            if (alive _unit && {_unit distance _pos < 0.8}) then {
                [QGVAR(OnCheckBody), [_unit, group _unit, _body]] call FUNC(eventCallback);
                _unit action ["rearm", _body];
                _unit doFollow leader group _unit;
            };
        },
        [_unit, time + 8, _body]
    ] call CBA_fnc_waitUntilAndExecute;

    // update variable
    _body setVariable [QGVAR(isChecked), true, true];

    // debug
    if (GVAR(debug_functions)) then {systemchat format ["%1 checking body (%2 %3m)", side _unit, name _unit, round (_unit distance _body)];};

    // end
    true
};

// end
false
