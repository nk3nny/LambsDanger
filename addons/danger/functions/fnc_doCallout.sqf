#include "script_component.hpp"
/*
 * Author: joko // Jonas
 *
 *
 * Arguments:
 * 0:
 *
 * Return Value:
 *
 *
 * Example:
 *
 *
 * Public: No
*/

params ["_unit", "_behavior", "_callout","_distance"];
private _speaker = speaker _unit;
private _cacheName = format [QGVAR(%1_%2_%3), _speaker, _behavior, _callout];
private _cachedSounds = GVAR(CalloutCacheNamespace) getVariable _cacheName;

if (isNil "_cachedSounds") then {
    private _protocolConfig = (configFile >> (getText (configFile >> (getText (configfile >> "CfgVoice" >> _speaker >> "protocol")))));

    if (_behavior != "") then {
        _protocolConfig = _protocolConfig >> _behavior;
    };

    private _calloutConfigName = switch (toLower(_callout)) do {
        default {
            ""
        };
    };

    if (_calloutConfigName == "") exitWith {};

    _cachedSounds = getArray (_protocolConfig >> _calloutConfigName);

    GVAR(CalloutCacheNamespace) setVariable [_cacheName, _cachedSounds];
};

if (_cachedSounds isEqualTo []) exitWith {};

private _sound = selectRandom _cachedSounds;
if ( _sound == "") exitWith {};

playSound3D [_sound, _unit, isNull (objectParent _unit), getPosASL _unit, 1, pitch _unit, 50];
[_unit, true] remoteExecCall ["setRandomLip", 0];
[{
    [_unit, false] remoteExecCall ["setRandomLip", 0];
}, [], 1] CBA_fnc_waitAndExecute;
