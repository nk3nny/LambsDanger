#include "script_component.hpp"
/*
 * Author: jokoho482
 * Search pattern. Makes the unit patrol in the direction of hostile players
 *
 * Arguments:
 * Arma 3 Module Function Parameters
 *
 * Return Value:
 * NONE
 *
 * Public: No
*/
params [["_mode", "", [""]], ["_input", [], [[]]]];

switch (_mode) do {
    // Default object init
    case "init": {
        if (is3DEN) exitWith {};
        _input params [["_logic", objNull, [objNull]], ["_isActivated", true, [true]], ["_isCuratorPlaced", false, [true]]];
        if !(_isActivated && local _logic) exitWith {};
        if (_isCuratorPlaced) then {
            //--- Get unit under cursor
            private _group = GET_CURATOR_GRP_UNDER_CURSOR;

            //--- Check if the unit is suitable
            private _error = "";
            if (isNull _group) then {
                _error = LELSTRING(main,NoUnitSelected);
            };

            if (_error == "") then {
                [LSTRING(Module_TaskHunt_DisplayName),
                    [
                        [LSTRING(Module_TaskHunt_Radius_DisplayName), "SLIDER", LSTRING(Module_TaskHunt_Radius_ToolTip), [25, 5000], [1, 0.5], TASK_HUNT_SIZE, 1],
                        [LSTRING(Module_TaskHunt_CycleTime_DisplayName), "SLIDER", LSTRING(Module_TaskHunt_CycleTime_ToolTip), [1, 300], [1, 0.5], TASK_HUNT_CYCLETIME, 2],
                        [LSTRING(Module_TaskHunt_MovingCenter_DisplayName), "BOOLEAN", LSTRING(Module_TaskHunt_MovingCenter_ToolTip), TASK_HUNT_MOVINGCENTER],
                        [LSTRING(Module_TaskHunt_PlayersOnly_DisplayName), "BOOLEAN", LSTRING(Module_TaskHunt_PlayersOnly_ToolTip), TASK_HUNT_PLAYERSONLY],
                        [LSTRING(Module_Task_EnableReinforcement_DisplayName), "BOOLEAN", LSTRING(Module_Task_EnableReinforcement_ToolTip), TASK_HUNT_ENABLEREINFORCEMENT],
                        [LSTRING(Module_TaskHunt_TryUGLFlare_DisplayName), "DROPDOWN", LSTRING(Module_TaskHunt_TryUGLFlare_Tooltip), ["str_disabled", "str_enabled", LSTRING(OnlyIfUGL)], TASK_HUNT_TRYUGLFLARE]
                    ], {
                        params ["_data", "_args"];
                        _args params ["_group", "_logic"];
                        _data params ["_range", "_cycle", "_movingCenter", "_playerOnly", "_enableReinforcement", "_doUGL"];
                        _args = [_group, _range, _cycle, nil, nil, _playerOnly, _enableReinforcement, _doUGL];
                        if !(_movingCenter) then {
                            _args set [4, getPos _logic];
                        };
                        [QGVAR(taskHunt), _args, leader _group] call CBA_fnc_targetEvent;
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
        } else {
            private _groups = (synchronizedObjects _logic) apply {group _x};
            _groups = _groups arrayIntersect _groups;

            private _area = _logic getVariable ["objectarea", [TASK_HUNT_SIZE, TASK_HUNT_SIZE, 0, false, -1]];
            private _range = _area select ((_area select 0) < (_area select 1));
            private _cycle = _logic getVariable [QGVAR(CycleTime), TASK_HUNT_CYCLETIME];
            private _movingCenter = _logic getVariable [QGVAR(MovingCenter), TASK_HUNT_MOVINGCENTER];
            private _playerOnly = _logic getVariable [QGVAR(PlayersOnly), TASK_HUNT_PLAYERSONLY];
            private _enableReinforcement = _logic getVariable [QGVAR(EnableReinforcement), TASK_HUNT_ENABLEREINFORCEMENT];
            private _doUGL = _logic getVariable [QGVAR(doUGL), TASK_HUNT_TRYUGLFLARE];

            {
                private _args = [_x, _range, _cycle, _area, nil, _playerOnly, _enableReinforcement, _doUGL];
                if !(_movingCenter) then {
                    _args set [4, getPos _logic];
                };
                [QGVAR(taskHunt), _args, leader _x] call CBA_fnc_targetEvent;
            } forEach _groups;
            deleteVehicle _logic;
        };
    };
};
