#include "script_component.hpp"

params ["_logic", "", "_activated"];

if (_activated && local _logic) then {

    //--- Get unit under cursor
    private _group = GET_CURATOR_GRP_UNDER_CURSOR;

    //--- Check if the unit is suitable
    private _error = "";
    if (isNull _group) then {
        _error = LELSTRING(main,NoGroupSelected);
    };

    if (_error isEqualTo "") then {
        [LSTRING(Module_DisableGroupAI_DisplayName),
            [
                [LSTRING(Module_DisableGroupAI_SettingName), "BOOLEAN", LSTRING(Module_DisableGroupAI_SettingToolTip), _group getVariable [QGVAR(disableGroupAI), false], ""],
                [LSTRING(Module_EnableGroupReinforce_SettingName), "BOOLEAN", LSTRING(Module_EnableGroupReinforce_SettingToolTip), _group getVariable [QGVAR(enableGroupReinforce), false], ""]
            ], {
                params ["_data", "_args"];
                _args params ["_group", "_logic"];
                _data params ["_disableGroupAI", "_enableGroupReinforce"];
                _group setVariable [QGVAR(disableGroupAI), _disableGroupAI, true];
                _group setVariable [QGVAR(enableGroupReinforce), _enableGroupReinforce, true];
                deleteVehicle _logic;
            }, {
                params ["", "_logic"];
                deleteVehicle _logic;
            }, {
                params ["", "_logic"];
                deleteVehicle _logic;
            }, [_group, _logic]
        ] call EFUNC(main,showDialog);
    } else {
        [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
        deleteVehicle _logic;
    };
};
