#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"
GVAR(CQBClearHash) = [[], []] call CBA_fnc_hashCreate;
GVAR(SideArtilleryHash) = [[], []] call CBA_fnc_hashCreate;
ADDON = true;
