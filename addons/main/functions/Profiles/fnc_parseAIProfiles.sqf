#include "script_component.hpp"
/*
 * Author: joko // Jonas
 *
 *
 * Arguments:
 *
 *
 * Return Value:
 *
 *
 * Example:
 *
 *
 * Public: No
*/

{
    {
        private _profileName = toLower(configName _x);
        private _profile = GVAR(ProfilesNamespace) getVariable _profileName;
        if (isNil "_profile") then {
            _profile = createHashMap;
        };
        {
            private _value = false;
            private _tactic = toLower(configName _x);
            if (isText _x) then {
                _value = getText _x;
                if (toLower(_value) in ["true", "false"]) then {
                    switch (toLower _value) do {
                        case ("true"): {
                            _value = true;
                        };
                        default {
                            _value = false;
                        };
                    };
                } else {
                    _value = compile _value;
                };
            } else {
                if (isNumber _x) then {
                    _value = getNumber _x;
                };
            };
            _profile set [_tactic, _value];
        } forEach configProperties [_x, "!isClass _x", true];
        GVAR(ProfilesNamespace) setVariable [_profileName, _profile, true];
    } forEach configProperties [_x >> "LAMBS_CfgAIProfiles", "isClass _x", true];
} forEach [configFile, missionConfigFile];
