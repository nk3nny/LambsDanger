#include "script_component.hpp"

GVAR(drawRectCacheGame) = [];
GVAR(drawRectInUseGame) = [];

GVAR(drawRectCacheEGSpectator) = [];
GVAR(drawRectInUseEGSpectator) = [];
addMissionEventHandler ["Draw3D", { call FUNC(debugDraw); }];
