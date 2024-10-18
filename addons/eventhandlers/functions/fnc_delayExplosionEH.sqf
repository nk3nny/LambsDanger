#include "script_component.hpp"
/*
 * Author: Lambda.Tiger
 * Delayed reaction to explosions. The delay is calculated on
 * a) A base line of reaction time
 * b) Distance from the explosion
 * c) AI general skill
 *
 * Arguments:
 * BIS Explosion EH
 *
 * Return Value:
 * None
 *
 * Example:
 * [BIS EXPLOSION EH ARGS] call lambs_eventhandlers_fnc_explosionEH;
 *
 * Public: No
*/
params [
    ["_unit", objNull],
    "",
    ["_explosionSource", objNull]
];

if (!alive _unit ||
    !(local _unit) ||
    isPlayer _unit) exitWith {};

private _skill = _unit skill "general";
private _timeOfFlight = (_unit distance _explosionSource) / 343; // 343 m/s - good value for speed of sound
// min delay of 160 ms based on
// EFFECTS OF PREKNOWLEDGE AND STIMULUS INTENSITY UPON SIMPLE REACTION TIME by J. M. Speiss
// Loudness and reaction time: I by D. L. Kohfeld, J. L. Santee, and N. D. Wallace
[{_this call FUNC(explosionEH)}, _this, 0.16 + _timeOfFlight + 0.2 * (1 - random _skill)] call CBA_fnc_waitAndExecute;
