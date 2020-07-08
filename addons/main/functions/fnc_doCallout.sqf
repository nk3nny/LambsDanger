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
 * [bob, "Normal", "ManDown", 100] call lambs_main_fnc_doCallout;
 *
 * Public: Yes
*/

if (GVAR(disableAICallouts)) exitWith {};

scopeName QGVAR(doCallout_main);
params [
    ["_unit", objNull, [objNull]],
    ["_behavior", "", [""]],
    ["_callout", "micout", [""]],
    ["_distance", 100, [0]]
];

if (isPlayer _unit || {!(_unit call EFUNC(main,isAlive))}) exitWith {};

// check timing
private _time = _unit getVariable [QGVAR(calloutTime), 0];
if (_time >= time) exitWith {
    if (GVAR(debug_functions)) then {
        format ["%1 callout too early (%2 in %3s)", side _unit, name _unit, time - _time] call FUNC(debugLog);
    };
};

private _speaker = speaker _unit;
private _cacheName = format ["%1_%2_%3_%4", QGVAR(callouts), _speaker, _behavior, _callout];
private _cachedSounds = GVAR(CalloutCacheNamespace) getVariable _cacheName;

if (isNil "_cachedSounds") then {
    private _protocolConfig = configFile >> (getText (configFile >> "CfgVoice" >> _speaker >> "protocol")) >> "Words";
    if (_behavior != "" && {isClass (_protocolConfig >> _behavior)}) then {
        _protocolConfig = _protocolConfig >> _behavior;
    };

    private _calloutConfigName = switch (toLower(_callout)) do {
        case ("contact"): {
            selectRandom ["ContactE_1", "ContactE_2", "ContactE_3", "Danger"];
        };
        case ("grenadeout"): {
            selectRandom ["ThrowingGrenadeE_1", "ThrowingGrenadeE_2", "ThrowingGrenadeE_3"];
        };
        case ("mandown"): {
            selectRandom ["ManDownE", "WeLostOneE", "WeGotAManDownE"];
        };
        case ("suppress"): {
            selectRandom ["CombatGenericE", "CheeringE", "SuppressingE", "Suppressing"]
        };
        case ("panic"): {
            selectRandom ["HealthSomebodyHelpMe", "HealthNeedHelp", "HealthWounded", "HealthMedic", "CombatGenericE"]
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
        if (_sound select [0, 1] == "\") then {
            _sound = _sound select [1];
        };
        _cachedSounds set [_forEachIndex, _sound];
    } forEach _cachedSounds;

    GVAR(CalloutCacheNamespace) setVariable [_cacheName, _cachedSounds];
};

// no sounds found
if (_cachedSounds isEqualTo []) exitWith {};

private _sound = selectRandom _cachedSounds;
if (_sound == "") exitWith {};
playSound3D [_sound, _unit, isNull (objectParent _unit), getPosASL _unit, 5, pitch _unit, _distance];
[_unit, true] remoteExecCall ["setRandomLip", 0];
[{
    _this remoteExecCall ["setRandomLip", 0];
}, [_unit, false], 1] call CBA_fnc_waitAndExecute;
if (GVAR(debug_functions)) then {
    format ["%1 callout (%2 called %3!)", side _unit, name _unit, _callout] call FUNC(debugLog);
};

// set time until next callout
_unit setVariable [QGVAR(calloutTime), time + 4, true];
