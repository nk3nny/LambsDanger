#include "script_component.hpp"
/*
 * Author: joko // Jonas
 *
 *
 * Arguments:
 * 0: Unit that does the Callout <OBJECT>
 * 1: Current Unit Behavior <STRING>
 * 2: Call out <STRING>
 * 3: Distance the callout is heard <NUMBER> (default: 10)
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [bob, "CombatEngage", "ManDownE", 10] call lambs_danger_fnc_doCallout;
 *
 * Public: No
*/
scopeName QGVAR(doCallout_main);
params [["_unit", objNull, [objNull]], ["_behavior", ""], ["_callout", "micout"], ["_distance", 10]];
private _speaker = speaker _unit;
private _cacheName = format [QGVAR(%1_%2_%3), _speaker, _behavior, _callout];
private _cachedSounds = GVAR(CalloutCacheNamespace) getVariable _cacheName;

if (isNil "_cachedSounds") then {
    private _protocolConfig = configFile >> (getText (configFile >> "CfgVoice" >> _speaker >> "protocol")) >> "Words";
    if (_behavior != "") then {
        _protocolConfig = _protocolConfig >> _behavior;
    };

    private _calloutConfigName = switch (toLower(_callout)) do {
        case ("contact"): {
            selectRandom ["ContactE_1", "ContactE_2", "ContactE_3"];
        };
        case ("grenadeout"): {
            selectRandom ["ThrowingGrenadeE_1", "ThrowingGrenadeE_2", "ThrowingGrenadeE_3"];
        };
        case ("mandown"): {
            selectRandom ["ManDownE", "WeLostOneE", "WeGotAManDownE"];
        };
        default {
            if (isArray (_protocolConfig >> _callout)) then {
                _callout;
            } else {
                "";
            };
        };
    };

    if (_calloutConfigName == "") exitWith {
        breakOut QGVAR(doCallout_main);
    };

    _cachedSounds = getArray (_protocolConfig >> _calloutConfigName);

    {
        private _sound = _x;
        if (_sound select [0, 1] != "\") then {
            _sound = (getArray (configFile >> "CfgVoice" >> _speaker >> "directories") select 0) + _sound;
        };
        _cachedSounds set [_forEachIndex, _sound];
    } forEach _cachedSounds;

    GVAR(CalloutCacheNamespace) setVariable [_cacheName, _cachedSounds];
};

if (_cachedSounds isEqualTo []) exitWith {};

private _sound = selectRandom _cachedSounds;
if (_sound == "") exitWith {};
playSound3D [_sound, _unit, isNull (objectParent _unit), getPosASL _unit, 1, pitch _unit, _distance];
[_unit, true] remoteExecCall ["setRandomLip", 0];
[{
    _this remoteExecCall ["setRandomLip", 0];
}, [_unit, false], 1] call CBA_fnc_waitAndExecute;
