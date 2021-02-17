#include "script_component.hpp"

GVAR(CalloutCacheNamespace) = call CBA_fnc_createNamespace;

{
    private _controls = missionNamespace getVariable [_x, []];
    if !(_controls isEqualTo []) then {
        {
            if !(isNull _x) then {
                ctrlDelete _x
            };
        } forEach _controls;
    };
    missionNamespace setVariable [_x, []];
} foreach [
    QGVAR(debug_drawRectCacheGame),
    QGVAR(debug_drawRectInUseGame),
    QGVAR(debug_drawRectCacheEGSpectator),
    QGVAR(debug_drawRectInUseEGSpectator),
    QGVAR(debug_drawRectCacheCurator),
    QGVAR(debug_drawRectInUseCurator)
];

addMissionEventHandler ["Draw3D", { call FUNC(debugDraw); }];
