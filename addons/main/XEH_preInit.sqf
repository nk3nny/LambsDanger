#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"
#include "settings.sqf"
GVAR(ChooseDialogSettingsCache) = false call CBA_fnc_createNamespace;

// check for WP module
GVAR(Loaded_WP) = isClass (configfile >> "CfgPatches" >> "lambs_wp");

GVAR(shareHandlers) = [];

GVAR(blockSuppressionModelCache) = false call CBA_fnc_createNamespace;

GVAR(minObstacleProximity) = 5;

ADDON = true;
