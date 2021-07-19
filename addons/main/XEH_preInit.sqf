#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"
#include "settings.sqf"

// check for WP module
GVAR(Loaded_WP) = isClass (configfile >> "CfgPatches" >> "lambs_wp");

GVAR(shareHandlers) = [];

GVAR(blockSuppressionModelCache) = createHashMap;
GVAR(CalloutCacheNamespace) = createHashMap;
GVAR(ChooseDialogSettingsCache) = createHashMap;

GVAR(minObstacleProximity) = 5;

ADDON = true;
