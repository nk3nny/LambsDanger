#include "script_component.hpp"
// Immediate reaction on explosion
// version 1.5
// by nkenny

// init
params ["_unit"];

// Standing or recent explosions ignored
if (
    isplayer _unit
    || {!isNull objectParent _unit}
    || {stance _unit isEqualTo "PRONE"}
    || {_unit getVariable [QGVAR(isExploded),0] > time}
) exitWith {false};

// settings
private _pos = _unit getPos [4,random 360];
private _dir = 360 - (_unit getRelDir _pos);
_unit setVariable [QGVAR(isExploded), time + 9];

// standing to Right prone
if (_dir > 330 && { random 1 > 0.2 }) exitWith {
    _unit switchMove "AmovPercMstpSrasWrflDnon_AadjPpneMstpSrasWrflDleft";
    [
        {
            if (alive _this) then {
                _this switchMove "AadjPpneMstpSrasWrflDleft_AmovPercMstpSrasWrflDnon"
            };
        }, _unit, 4 + random 3
    ] call CBA_fnc_waitAndExecute;
};

// standing to Left prone
if (_dir < 30 && { random 1 > 0.2 }) exitWith {
    _unit switchMove "AmovPercMstpSrasWrflDnon_AadjPpneMstpSrasWrflDright";
    [
        {
            if (alive _this) then {
                _this switchMove "AadjPpneMstpSrasWrflDright_AmovPercMstpSrasWrflDnon"
            };
        }, _unit, 4 + random 3
    ] call CBA_fnc_waitAndExecute;
};

// update pos
_pos = (_unit getPos [ 3, _pos getDir _unit ]);

// Execute move
_unit doMove _pos;
_unit doWatch _pos;

// all others ~ go straight down
_unit switchMove "AmovPercMsprSlowWrflDf_AmovPpneMstpSrasWrflDnon";
_unit setUnitPos "DOWN";

// get back
[
    {
        if (alive _this) then {
        _this setUnitPos "AUTO"
        };
    }, _unit, 5 + random 3
] call CBA_fnc_waitAndExecute;

// end
true
