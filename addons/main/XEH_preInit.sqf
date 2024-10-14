#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"
#include "settings.inc.sqf"
GVAR(ChooseDialogSettingsCache) = false call CBA_fnc_createNamespace;

// check for WP module
GVAR(Loaded_WP) = isClass (configFile >> "CfgPatches" >> "lambs_wp");

GVAR(shareHandlers) = [];

GVAR(blockSuppressionModelCache) = false call CBA_fnc_createNamespace;

if (isServer) then {
    GVAR(versionLoadedOnServer) = QUOTE(VERSION_STR);
    publicVariable QGVAR(versionLoadedOnServer);
} else {
    0 spawn {
        waitUntil {time > 0};
        if (!isNil QGVAR(versionLoadedOnServer) && {GVAR(versionLoadedOnServer) isEqualTo QUOTE(VERSION_STR)}) exitWith {};

        private _error = if (isNil QGVAR(versionloadedonServer)) then {
            "LAMBS DANGER NOT LOADED ON SERVER!" hintC parsetext format [
                "Lambs Danger is not loaded on server but on Client!"
            ];
            "Lambs Danger is not loaded on server but on Client!"
        } else {
            "LAMBS DANGER VERSION MISMATCH ERROR!!!!" hintC parsetext format [
                "Lambs Danger Version mismatch Error.<br/>Client Version: %1<br/>Server Version: %2",
                QUOTE(VERSION_str),
                GVAR(versionloadedonServer)
            ];
            format [
                "Lambs Danger Version mismatch Error. Client Version: %1 Server Version: %2",
                QUOTE(VERSION_str),
                GVAR(versionloadedonServer)
            ];
        };

        while {true} do {
            hintSilent _error;
            systemChat _error;
            diag_log text _error;
            sleep 1;
        };
    };
};

ADDON = true;
