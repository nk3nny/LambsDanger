#include "script_component.hpp"
/*
 * Author: joko // Jonas
 * Group profiles handler -- Checks and runs AI profiles -- group actions with the fnc_profileXxx prefix.
 *
 * Arguments:
 * 0: Group/Unit <OBJECT, GROUP>
 * 1: Profile Tactic <STRING>
 *
 * Return Value:
 * Tactic is allowed to Execute
 *
 * Example:
 * [bob] call lambs_danger_fnc_doesProfileAllow;
 *
 * Public: No
*/
params [["_target", objNull, [objNull, grpNull]], ["_tactic", "unkown", [""]]];

private _profile = _target getVariable [QGVAR(AIProfile), GVAR(defaultAIProfile)];

private _profileData = GVAR(ProfilesNamespace) getVariable toLower(_profile);
if (isNil "_profileData") then {
    _profileData = GVAR(ProfilesNamespace) getVariable "Default";
};
_tactic = toLower(_tactic);
private _value = [_profileData, _tactic] call CBA_fnc_hashGet;

// Simple Unit/Group Based Overwrite
private _overwrite = _target getVariable QGVAR(OverwriteProfile);
if (!isNil "_overwrite" && { _overwrite isEqualType [] } && { [_overwrite, _tactic] call CBA_fnc_hashHasKey }) then {
    _value = [_overwrite, _tactic] call CBA_fnc_hashGet;
};

if (_value isEqualType {}) then {
    _value = [_target, _tactic] call _value;
};
if (_value isEqualType 0) then {
    if (_value in [1,0]) then {
        _value = _value isEqualTo 1;
    } else {
        _value = RND(_value);
    };
};
if !(_value isEqualType true) then {
    _value = true;
};
_value;
