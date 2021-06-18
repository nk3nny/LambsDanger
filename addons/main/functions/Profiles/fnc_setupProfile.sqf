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
 * [bob] call lambs_danger_fnc_setupProfile;
 *
 * Public: Yes
*/
params ["_profileName", "_tactics"];
private _profileName = toLower _profileName;
private _profile = +GVAR(ProfilesNamespace) getVariable "default"; // Create a Copy of the default Profile

{
    _profile set [toLower(_x select 0), _x select 1];
} forEach _tactics;

GVAR(ProfilesNamespace) setVariable [_profileName, _profile, true];
