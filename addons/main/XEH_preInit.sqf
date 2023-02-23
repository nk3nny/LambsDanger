#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"
#include "settings.sqf"
GVAR(ChooseDialogSettingsCache) = false call CBA_fnc_createNamespace;

// check for WP module
GVAR(Loaded_WP) = isClass (configfile >> "CfgPatches" >> "lambs_wp");

GVAR(shareHandlers) = [];

GVAR(blockSuppressionModelCache) = false call CBA_fnc_createNamespace;

if (isServer) then {
    GVAR(versionLoadedOnServer) = QUOTE(VERSION_STR);
    publicVariable QGVAR(versionLoadedOnServer);
} else {
    0 spawn {
        if (!isNil QGVAR(versionLoadedOnServer) && GVAR(versionLoadedOnServer) isEqualTo QUOTE(VERSION_STR)) exitWith {};
        "LAMBS DANGER VERSION MISMATCH ERROR!!!!" hintC parseText format [
            "Lambs Danger Version mismatch Error.<br/>Client Version: %1<br/>Server Version: %2",
            QUOTE(VERSION_STR),
            GVAR(versionLoadedOnServer)
        ];
        private _error = format [
            "Lambs Danger Version mismatch Error. Client Version: %1 Server Version: %2",
            QUOTE(VERSION_STR),
            GVAR(versionLoadedOnServer)
        ];
        while {true} do {
            hintSilent _error;
            systemChat _error;
            diag_log text _error;
            sleep 1;
        };
    };
};

ADDON = true;
