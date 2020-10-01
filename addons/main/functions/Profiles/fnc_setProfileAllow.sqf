#include "script_component.hpp"
/*
 * Author: joko // Jonas
 * Group profiles handler -- Checks and runs AI profiles -- group actions with the fnc_profileXxx prefix.
 *
 * Arguments:
 * 0: Profile <STRING>
 * 1: Profile Tactic <STRING>
 * 2: Profile Enabled <BOOL>
 *
 * Return Value:
 * Tactic is allowed to Execute
 *
 * Example:
 * ["default", "tacticHidding", true] call lambs_danger_fnc_setProfileAllow;
 *
 * Public: No
*/
params [["_profileName", "", [""]], ["_tacticName", "", [""]], ["_enabled", true, [true, 0, {}]]];
_profileName = toLower(_profileName);
private _profile = GVAR(ProfilesNamespace) getVariable _profileName;
if (isNil "_profile") then {
    _profile = [[], true] call CBA_fnc_hashCreate;
};

_profile = [_profile, toLower(_tacticName), _enabled] call CBA_fnc_hashSet;

GVAR(ProfilesNamespace) setVariable [_profileName, _profile, true];
