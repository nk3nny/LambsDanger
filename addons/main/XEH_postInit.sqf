#include "script_component.hpp"

GVAR(CalloutCacheNamespace) = call CBA_fnc_createNamespace;

GVAR(debug_drawRectCacheGame) = [];
GVAR(debug_drawRectInUseGame) = [];

GVAR(debug_drawRectCacheEGSpectator) = [];
GVAR(debug_drawRectInUseEGSpectator) = [];

GVAR(debug_drawRectCacheCurator) = [];
GVAR(debug_drawRectInUseCurator) = [];
addMissionEventHandler ["Draw3D", { call FUNC(debugDraw); }];
