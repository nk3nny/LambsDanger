#include "script_component.hpp"
/*
 * Author: jokoho482
 * Creates an artillery target for a given side
 *
 * Arguments:
 * TODO
 *
 * Return Value:
 * TODO
 *
 * Example:
 * TODO
 *
 * Public: No
*/
params [["_mode", "", [""]], ["_input", [], [[]]]];

switch (_mode) do {
    // Default object init
    case "init": {
        if (is3DEN) exitWith {};
        _input params [["_logic", objNull, [objNull]], ["_isActivated", true, [true]], ["_isCuratorPlaced", false, [true]]];
        if !(_isActivated) exitWith {};
        private _fnc_callArtillery = {
            params ["_side", "_salvo", "_spread", "_skipCheckround", "_logic"];
            [{
                params ["_side", "", "", "", "_pos"];
                [_side, _pos] call FUNC(sideHasArtillery);
            }, {
                params ["_side", "_salvo", "_spread", "_skipCheckround", "_pos"];
                [_side, _pos, objNull, _salvo, _spread, _skipCheckround] call FUNC(taskArtillery);
            }, [_side, _salvo, _spread, _skipCheckround, getPos _logic]] call CBA_fnc_waitUntilAndExecute;
        };
        if (_isCuratorPlaced) then {
            [LSTRING(Module_TaskArtillery_DisplayName),
                [
                    [LSTRING(Module_TaskArtillery_Side_DisplayName), "SIDE", LSTRING(Module_TaskArtillery_Side_Tooltip), [west, east, independent]],
                    [LSTRING(Module_TaskArtillery_MainSalvo_DisplayName), "SLIDER", LSTRING(Module_TaskArtillery_MainSalvo_Tooltip), [1, 20], [2, 1], TASK_ARTILLERY_ROUNDS, 0],
                    [LSTRING(Module_TaskArtillery_Spread_DisplayName), "SLIDER", LSTRING(Module_TaskArtillery_Spread_Tooltip), [1, 200], [2, 1], TASK_ARTILLERY_SPREAD, 2],
                    [LSTRING(Module_TaskArtillery_SkipCheckrounds_DisplayName), "BOOLEAN", LSTRING(Module_TaskArtillery_SkipCheckrounds_Tooltip), TASK_ARTILLERY_SKIPCHECKROUNDS]
                ], {
                    params ["_data", "_args"];
                    _args params ["_logic", "_fnc_callArtillery"];
                    _data params ["_side", "_salvo", "_spread", "_skipCheckround"];
                    [_side, _salvo, _spread, _skipCheckround, _logic] call _fnc_callArtillery;
                    [objNull, format [LLSTRING(Module_TaskArtillery_ZeusNotification), [_side] call BIS_fnc_sideName]] call BIS_fnc_showCuratorFeedbackMessage;
                    deleteVehicle _logic;
                }, {
                    params ["_logic"];
                    deleteVehicle _logic;
                }, {
                    params ["_logic"];
                    deleteVehicle _logic;
                }, [_logic, _fnc_callArtillery]
            ] call EFUNC(main,showDialog);
        } else {
            private _sideIndex = _logic getVariable [QGVAR(Side), 0];
            private _salvo = _logic getVariable [QGVAR(MainSalvo), TASK_ARTILLERY_ROUNDS];
            private _spread = _logic getVariable [QGVAR(Spread), TASK_ARTILLERY_SPREAD];
            private _skipCheckround = _logic getVariable [QGVAR(SkipCheckRounds), TASK_ARTILLERY_SKIPCHECKROUNDS];
            [[west, east, independent] select _sideIndex, _salvo, _spread, _skipCheckround, _logic] call _fnc_callArtillery;

            deleteVehicle _logic;
        };
    };
};
true
