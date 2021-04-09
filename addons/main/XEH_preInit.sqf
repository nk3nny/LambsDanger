#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"
#include "settings.sqf"
GVAR(ChooseDialogSettingsCache) = false call CBA_fnc_createNamespace;

// check for WP module
GVAR(Loaded_WP) = isClass (configfile >> "CfgPatches" >> "lambs_wp");

if (isServer && !is3DEN) then {
    GVAR(ProfilesNamespace) = true call CBA_fnc_createNamespace;;
    publicVariable QGVAR(ProfilesNamespace);
    call FUNC(parseAIProfiles);
};
ADDON = true;
