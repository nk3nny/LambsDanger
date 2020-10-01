#include "script_component.hpp"

GVAR(CalloutCacheNamespace) = call CBA_fnc_createNamespace;

GVAR(drawRectCacheGame) = [];
GVAR(drawRectInUseGame) = [];

GVAR(drawRectCacheEGSpectator) = [];
GVAR(drawRectInUseEGSpectator) = [];

GVAR(drawRectCacheCurator) = [];
GVAR(drawRectInUseCurator) = [];
addMissionEventHandler ["Draw3D", { call FUNC(debugDraw); }];

if (isServer) then {
    GVAR(ProfilesNamespace) = true call CBA_fnc_createNamespace;
    publicVariable QGVAR(ProfilesNamespace);
    call FUNC(parseAIProfiles);
};
