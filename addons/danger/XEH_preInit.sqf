#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

#include "settings.sqf"

// mod check
GVAR(Loaded_WP) = isClass (configfile >> "CfgPatches" >> "lambs_wp");

ADDON = true;
