#include "script_component.hpp"
/*
 * Author: nkenny
 * Removes eventhandlers assigned by lambs modules
 *
 * Arguments:
 * 0: Unit to clean up <OBJECT>
 *
 * Return Value:
 * nil
 *
 * Example:
 * [bob] call lambs_main_removeEventhandlers;
 *
 * Public: No
*/
params ["_unit", "_ehs"];
{
    _unit removeEventHandler _x;
} forEach _ehs;
