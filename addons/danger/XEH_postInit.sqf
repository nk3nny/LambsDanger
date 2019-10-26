#include "script_component.hpp"

GVAR(drawRectCacheGame) = [];
GVAR(drawRectInUseGame) = [];

GVAR(drawRectCacheEGSpectator) = [];
GVAR(drawRectInUseEGSpectator) = [];

GVAR(drawRectCacheCurator) = [];
GVAR(drawRectInUseCurator) = [];
addMissionEventHandler ["Draw3D", { call FUNC(debugDraw); }];
