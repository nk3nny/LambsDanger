#include "script_component.hpp"
ADDON = false;

#include "settings.inc.sqf"

#include "XEH_PREP.hpp"


[QGVAR(incomingGrenade), {
    params ["_unit"];
    if (isPlayer _unit || _unit getVariable [QEGVAR(danger,disableAI), false]) exitWith {};
    [{call EFUNC(main,doCallout)}, [_unit, selectRandom ["Combat", "Stealth"], "grenadein"], random 2] call CBA_fnc_waitAndExecute;
    _unit setUnitPosWeak "DOWN";
}] call CBA_fnc_addEventhandler;

ADDON = true;
