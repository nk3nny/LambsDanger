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

#define SIDES [west, east, independent]
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
                private _artillery = [EGVAR(main,SideArtilleryHash), _side] call CBA_fnc_hashGet;
                _artillery = _artillery select {
                    canFire _x
                    && {unitReady _x}
                    && {_pos inRangeOfArtillery [[_x], getArtilleryAmmo [_x] select 0]};
                };
                !(_artillery isEqualTo [])
            }, {
                params ["_side", "_salvo", "_spread", "_skipCheckround", "_pos"];
                private _artillery = [EGVAR(main,SideArtilleryHash), _side] call CBA_fnc_hashGet;
                _artillery = [_artillery, [], { _pos distance _x }, "ASCEND"] call BIS_fnc_sortBy;
                _artillery = _artillery select {
                    canFire _x
                    && {unitReady _x}
                    && {_pos inRangeOfArtillery [[_x], getArtilleryAmmo [_x] select 0]};
                };
                [_artillery select 0, _pos, leader (_artillery select 0), _salvo, _spread, _skipCheckround] spawn FUNC(taskArtillery);
            }, [_side, _salvo, _spread, _skipCheckround, getPos _logic]] call CBA_fnc_waitUntilAndExecute;
        };
        if (_isCuratorPlaced) then {
            private _sides = SIDES apply { str _x };
            [LSTRING(Module_TaskArtillery_DisplayName),
                [
                    [LSTRING(Module_TaskArtillery_Side_DisplayName), "DROPDOWN", LSTRING(Module_TaskArtillery_Side_Tooltip), _sides],
                    [LSTRING(Module_TaskArtillery_MainSalvo_DisplayName), "NUMBER", LSTRING(Module_TaskArtillery_MainSalvo_Tooltip), 6],
                    [LSTRING(Module_TaskArtillery_Spread_DisplayName), "NUMBER", LSTRING(Module_TaskArtillery_Spread_Tooltip), 75],
                    [LSTRING(Module_TaskArtillery_SkipCheckrounds_DisplayName), "BOOLEAN", LSTRING(Module_TaskArtillery_SkipCheckrounds_Tooltip), false]
                ], {
                    params ["_data", "_args"];
                    _args params ["_logic", "_fnc_callArtillery"];
                    _data params ["_sideIndex", "_salvo", "_spread", "_skipCheckround"];
                    [SIDES select _sideIndex, _salvo, _spread, _skipCheckround, _logic] call _fnc_callArtillery;
                    [objNull, format [localize LSTRING(Module_TaskArtillery_ZeusNotification), SIDES select _sideIndex]] call BIS_fnc_showCuratorFeedbackMessage;
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
            private _salvo = _logic getVariable [QGVAR(MainSalvo), 6];
            private _spread = _logic getVariable [QGVAR(Spread), 75];
            private _skipCheckround = _logic getVariable [QGVAR(SkipCheckRounds), false];
            [SIDES select _sideIndex, _salvo, _spread, _skipCheckround, _logic] call _fnc_callArtillery;

            deleteVehicle _logic;
        };
    };
};
true
