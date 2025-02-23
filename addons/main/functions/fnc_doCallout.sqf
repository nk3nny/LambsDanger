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

params [
    ["_unit", objNull, [objNull]],
    ["_behavior", "", [""]],
    ["_callout", "micout", [""]],
    ["_distance", 100, [0]]
];

if (isPlayer _unit || {!(_unit call FUNC(isAlive))}) exitWith {};

// check timing
private _time = _unit getVariable [QGVAR(calloutTime), 0];
if (_time >= time) exitWith {
    if (GVAR(debug_functions)) then {
        ["%1 callout too early (%2 in %3s)", side _unit, name _unit, time - _time] call FUNC(debugLog);
    };
};

private _speaker = speaker _unit;
if (toUpperANSI(_speaker) in ["", "ACE_NOVOICE"]) exitWith {}; // Early Exit if Unit is "Mute"

switch (toLowerANSI(_callout)) do {
    case ("contact"): {
        _callout = selectRandom ["ContactE_1", "ContactE_2", "ContactE_3", "Danger"];
    };
    case ("grenadeout"): {
        _callout = selectRandom ["ThrowingGrenadeE_1", "ThrowingGrenadeE_2", "ThrowingGrenadeE_3"];
    };
    case ("mandown"): {
        _callout = selectRandom ["ManDownE", "WeLostOneE", "WeGotAManDownE"];
    };
    case ("suppress"): {
        _callout = selectRandom ["CombatGenericE", "CheeringE", "SuppressingE", "Suppressing"];
    };
    case ("panic"): {
        _callout = selectRandom ["HealthSomebodyHelpMe", "HealthNeedHelp", "HealthWounded", "HealthMedic", "CombatGenericE"];
    };
    case ("flank"): {
        _callout = selectRandom ["OnYourFeet", "Advance", "FlankLeft", "FlankRight"];
    };
    case ("eject"): {
        _callout = selectRandom ["Eject", "EndangeredE"];
    };
};

private _cacheName = format ["%1_%2_%3_%4", QGVAR(callouts), _speaker, _behavior, _callout];
private _cachedSounds = GVAR(CalloutCacheNamespace) getVariable _cacheName;

if (isNil "_cachedSounds") then {
    private _protocolConfig = configFile >> (getText (configFile >> "CfgVoice" >> _speaker >> "protocol")) >> "Words";
    if (_behavior != "" && {isClass (_protocolConfig >> _behavior)}) then {
        _protocolConfig = _protocolConfig >> _behavior;
    };

    _cachedSounds = getArray (_protocolConfig >> _callout);
    private _deleted = false;
    {
        private _sound = toLowerANSI _x;
        if (_sound == "") then {
            _deleted = true;
            _cachedSounds set [_forEachIndex, objNull];
            continue;
        };

        private _hasFileEnding = _sound regexMatch ".+?\.(?:ogg|wss|wav|mp3)$/io";

        if (_sound select [0, 1] != "\") then {
            _sound = (getArray (configFile >> "CfgVoice" >> _speaker >> "directories") select 0) + _sound;
        };
        if (_sound select [0, 1] == "\") then {
            _sound = _sound select [1];
        };

        if (!_hasFileEnding && {!fileExists _sound}) then {
            {
                if (fileExists (_sound + _x)) exitWith {
                    _sound = _sound + _x;
                };
            } forEach [".ogg", ".wss", ".wav", ".mp3"];
        };

        if (!_hasFileEnding || {!fileExists _sound}) then {
            _deleted = true;
            _cachedSounds set [_forEachIndex, objNull];
            continue;
        };

        _cachedSounds set [_forEachIndex, _sound];
    } forEach _cachedSounds;

    if (_deleted) then {
        _cachedSounds = _cachedSounds - [objNull];
    };

    GVAR(CalloutCacheNamespace) setVariable [_cacheName, _cachedSounds];
};

// no sounds found
if (_cachedSounds isEqualTo []) exitWith {
    if (GVAR(debug_functions)) then {
        private _str = ["WARNING: Callout %1 in behavior %3 for speaker %2 was not found!", "WARNING: Callout %1 for speaker %2 was not found!"] select (_behavior == "");
        private _arr = [_str, _callout, _speaker, _behavior];
        _arr call FUNC(debugLog);
        _arr call BIS_fnc_error;
    };
};

private _sound = selectRandom _cachedSounds;
playSound3D [_sound, _unit, isNull (objectParent _unit), eyePos _unit, 5, pitch _unit, _distance];
[_unit, true] remoteExecCall ["setRandomLip", 0];
[{
    _this remoteExecCall ["setRandomLip", 0];
}, [_unit, false], 1] call CBA_fnc_waitAndExecute;
if (GVAR(debug_functions)) then {
    ["%1 callout (%2 called %3!)", side _unit, name _unit, _callout] call FUNC(debugLog);
};

// set time until next callout
_unit setVariable [QGVAR(calloutTime), time + 4, true];
