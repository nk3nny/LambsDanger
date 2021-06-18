#include "script_component.hpp"
/*
 * Author: joko // Jonas
 * Group profiles handler -- Checks and runs AI profiles -- group actions with the fnc_profileXxx prefix.
 *
 * Arguments:
 * 0: Group/Unit <OBJECT, GROUP>
 * 1: Profile Tactic <STRING>
 * 2: Profile Default Value <ANYTHING>
 *
 * Return Value:
 * Value Stored in the Profile Tactic
 *
 * Example:
 * [bob] call lambs_danger_fnc_getProfileValue;
 *
 * Remarks:
 * Based on the 3rd parameter the type of return is getting defined.
 * If the value type of the profile tactic is a different to the _default type it the default gets returned.
 *
 *
 * Public: No
*/
params [["_target", objNull, [objNull, grpNull]], ["_tactic", "unkown", [""]], ["_default", true, [true, 0]]];

private _profile = _target getVariable [QGVAR(AIProfile), GVAR(defaultAIProfile)];

private _profileData = GVAR(ProfilesNamespace) getVariable _profile;
if (isNil "_profileData") then {
    _profileData = GVAR(ProfilesNamespace) getVariable "default";
};

// Simple Unit/Group Based Overwrite
private _overwrite = _target getVariable QGVAR(OverwriteProfile);
if (!isNil "_overwrite" && { _overwrite isEqualType [] } && { _tactic in _overwrite }) then {
    _profileData = _overwrite;
};

_tactic = toLower _tactic;
private _value = _profileData get _tactic;

if (_value isEqualType {}) then {
    _value = [_target, _tactic] call _value;
};
if (_value isEqualType 0) then {
    if (_default isEqualType true) then {
        _value = _value isEqualTo 1;
    };
};
_value;
