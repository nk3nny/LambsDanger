#include "script_component.hpp"
/*
 * Author: joko // Jonas
 *
 *
 * Arguments:
 *
 *
 * Return Value:
 *
 *
 * Example:
 *
 *
 * Public: No
*/
params ["_logic"];

if (_logic getVariable [QGVAR(skipInit), false]) exitWith {};
if (!local _logic) exitWith {};
private _type = typeOf _logic;
private _fnc = getText (configFile >> "CfgVehicles" >> _type >> "function");
if (_fnc isEqualTo "") exitWith {};

if (isNil _fnc) then {
    _fnc = compile _fnc;
} else {
    _fnc = missionNamespace getVariable _fnc;
};
private _is3DEN = (getNumber (configFile >> "CfgVehicles" >> _type >> "is3DEN")) == 1;
if (_is3DEN) then {
    [_fnc, ["init", [_logic, true, true]]] call CBA_fnc_execNextFrame;
} else {
    [_fnc, [_logic, true, true]] call CBA_fnc_execNextFrame;
};
