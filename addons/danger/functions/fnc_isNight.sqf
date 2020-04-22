#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit considers if it is night (necessary to shoot flares essentially)
 *
 * Arguments:
 * 0: Unit  <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, getpos angryJoe] call lambs_danger_fnc_isNight;
 *
 * Public: No
*/

params ["_unit"];

// stealth mode or has nightvision or global variable <-- TODO
if (behaviour _unit isEqualTo "STEALTH" 
    || {!( ( (assignedItems _unit) select 5 ) isEqualTo "" )}
    || {false}
) exitWith {false};

// night check
private _shift = date call BIS_fnc_sunriseSunsetTime;
(date select 3) < _shift select 0 || {(date select 3) > _shift select 1}