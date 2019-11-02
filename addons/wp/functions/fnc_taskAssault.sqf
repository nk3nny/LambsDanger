#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit rushes heedlessly to position with an option to be in forced retreat
 *
 * Arguments:
 * 0: Unit fleeing <OBJECT>
 * 1: Destination <ARRAY>
 * 2: Forced retreat, default false <BOOL>
 * 3: Distance threshold, default 10 <NUMBER>
 * 4: Update cycle, default 2 <NUMBER>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, getpos angryJoe] call lambs_wp_fnc_taskAssault;
 *
 * Public: Yes
*/

// init
params ["_group","_pos",["_retreat",false],["_threshold",12],["_cycle",2]];

// sort grp
if (!local _group) exitWith {};
_group = _group call CBA_fnc_getGroup;
_group setFormation "DIAMOND";
_group setBehaviourStrong "CARELESS";

// sort pos
_pos = _pos call CBA_fnc_getPos;

// sort group
private _units = units _group; 

// override
if ((_group getVariable [QEGVAR(danger,forcedMovement),-1]) != -1) then {
    (_group getVariable QEGVAR(danger,forcedMovement)) call CBA_fnc_removePerFrameHandler;
};

// individuals
{
    _x setVariable [QEGVAR(danger,dangerDisabled),true];
    _x forceSpeed 25;
    _x setUnitPos "UP";
    _x disableAI "FSM";
    _x disableAI "AUTOTARGET";
    _x disableAI "TARGET";
    _x disableAI "COVER";
    _x disableAI "SUPPRESSION";
    _x disableAI "CHECKVISIBLE";
    _x doMove _pos;
    _x doWatch _pos;
    if (_retreat) then {
        _x playMoveNow selectRandom [
            "ApanPknlMsprSnonWnonDf",
            "ApanPknlMsprSnonWnonDf",
            "ApanPercMsprSnonWnonDf"
        ];
    };
} foreach _units;

// Function ~ reached spot!
private _fnc_reached = {
    _this playMoveNow selectRandom [
        "AmovPercMsprSlowWrflDf_AmovPpneMstpSrasWrflDnon",
        "AmovPercMevaSrasWrflDf_AmovPknlMstpSrasWrflDnon",
        "AmovPercMevaSrasWrflDfl_AmovPknlMstpSrasWrflDnon",
        "AmovPercMevaSrasWrflDfr_AmovPknlMstpSrasWrflDnon"
    ];
    _this setVariable [QEGVAR(danger,dangerDisabled),nil];
    _this setUnitPos "DOWN";
    _this enableAI "FSM";
    _this enableAI "AUTOTARGET";
    _this enableAI "TARGET";
    _this enableAI "COVER";
    _this enableAI "SUPPRESSION";
    _this enableAI "CHECKVISIBLE";
    //_this doMove getposASL _this;
};

// Function ~ restore
private _fnc_restore = {
    params ["_unit","_handle"];
    if (_handle != (_group getVariable [QEGVAR(danger,forcedMovement),-1])) exitWith {};
    _unit forceSpeed -1;
    _unit setUnitPos "AUTO";
    _unit doFollow leader _unit;
};

// execute assault
private _handle = [
    {
        params ["_arg","_handle"];
        _arg params ["_group","_pos","_threshold","_units","_fnc_reached","_fnc_restore"];

        // Update units
        {
            // move
            _x doMove _pos;

            // clear targets ~ forget all targets. Harsh, but effective. - nkenny
            if (currentCommand _x isEqualTO "ATTACK") then {
                [_x] joinSilent grpNull;
                [_x] joinSilent _group;
            };

            // dead and units near destination get cleaned up!
            if (!alive _x || {_x distance _pos < (_threshold + random 4)}) then {
                _units deleteAt _forEachIndex;
                if (alive _x) then {
                    _x call _fnc_reached;
                    [_fnc_restore, [_x,_handle], 7 + random 6] call CBA_fnc_waitAndExecute;
                };
            };
        } foreach _units;

        // end or override
        if (count _units < 1) then {
            _handle call CBA_fnc_removePerFrameHandler;
            _group setVariable [QEGVAR(danger,forcedMovement),-1];
            _group setVariable [QEGVAR(danger,dangerAI), "enabled"];
            _group setBehaviour "AWARE";
        };
    }, _cycle, [_group, _pos, _threshold, _units, _fnc_reached, _fnc_restore]
] call CBA_fnc_addPerFrameHandler;

// handle
_group setVariable [QEGVAR(danger,forcedMovement),_handle];

// debug
if (EGVAR(danger,debug_functions)) then {systemchat format ["%1 %2: Unit moving %3m",side _group, ["taskAssault", "taskRetreat"] select _retreat, round (leader _group distance _pos)];};

// end
true
