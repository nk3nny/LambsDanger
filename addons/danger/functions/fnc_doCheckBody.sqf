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
 * [bob, getPos angryJoe, 10] call lambs_danger_fnc_doCheckBody;
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
    || {currentCommand _unit in ["GET IN", "ACTION", "HEAL"]}
) exitWith {false};

// look at it
_unit lookAt _pos;

// leaders gesture
[formationLeader _unit, ["gesturePoint"]] call EFUNC(main,doGesture);

// if too far away
if (_unit distance _pos > GVAR(CQB_range)) exitWith {false};

// half chance-- indoors
if (RND(0.5) && { _unit call EFUNC(main,isIndoor) }) exitWith {false};

// find body
private _body = allDeadMen select { (_x distance _pos) < _range };

// no body found
if (_body isEqualTo []) exitWith {false};

// ready
doStop _unit;

// found body
_body = selectRandom _body;

_unit setVariable [QGVAR(currentTarget), _body, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Check Body", EGVAR(main,debug_functions)];

// do it
private _bodyPos = getPosATL _body;
_unit doMove _bodyPos;
_unit forceSpeed ([_unit, _bodyPos] call FUNC(assaultSpeed));
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
        };
    },
    [_unit, _body], 8,
    {
        // on timeout
        params ["_unit"];
        if (_unit call EFUNC(main,isAlive)) then {_unit doFollow leader _unit};
    }
] call CBA_fnc_waitUntilAndExecute;

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 checking body (%2 @ %3m)", side _unit, name _unit, round (_unit distance _body)] call EFUNC(main,debugLog);

    // debug arrow
    private _help = createSimpleObject ["Sign_Arrow_Large_Yellow_F" ,getPosASL _body, true ];
    _help setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
    [{deleteVehicle _this}, _help, 8] call CBA_fnc_waitAndExecute;
};

// end
true
