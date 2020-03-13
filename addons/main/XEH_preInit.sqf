#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"
GVAR(CQBClearHash) = [[], []] call CBA_fnc_hashCreate;
GVAR(SideArtilleryHash) = [[], []] call CBA_fnc_hashCreate;
GVAR(ChooseDialogSettingsCache) = false call CBA_fnc_createNamespace;
ADDON = true;
