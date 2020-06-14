#include "script_component.hpp"

GVAR(CalloutCacheNamespace) = call CBA_fnc_createNamespace;

GVAR(drawRectCacheGame) = [];
GVAR(drawRectInUseGame) = [];

GVAR(drawRectCacheEGSpectator) = [];
GVAR(drawRectInUseEGSpectator) = [];

GVAR(drawRectCacheCurator) = [];
GVAR(drawRectInUseCurator) = [];
addMissionEventHandler ["Draw3D", { call FUNC(debugDraw); }];
