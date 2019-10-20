/*
 * Author: nkenny
 * Unit rushes heedlessly to position
 *
 * Arguments:
 * 0: Unit fleeing <OBJECT>
 * 1: Destination <ARRAY>
 * 2: Distance threshold, default 10 <NUMBER>
 * 3: Update cycle, default 2 <NUMBER>
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
params ["_group","_pos",["_threshold",10],["_cycle",2]];

// sort grp
if (!local _group) exitWith {};
_group = _group call CBA_fnc_getGroup;
_group setFormation "DIAMOND";
_group setBehaviourStrong "CARELESS";

// sort pos
_pos = _pos call CBA_fnc_getPos;

// sort group
private _units = units _group; 

// debug
systemchat format ["%1 to %2m",_group,round (leader _group distance _pos)];
arrow1 setpos _pos;

// override
if ((_group getVariable ["lambs_danger_forcedMovement",-1]) != -1) then {
    (_group getVariable "lambs_danger_forcedMovement") call CBA_fnc_removePerFrameHandler;
    systemChat "deleted old frame handler!";
};

// individuals
{
    _x setVariable ["lambs_danger_dangerDisabled",true];
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
} foreach _units;

// Function ~ reached spot!
private _fnc_reached = {
    _this playMoveNow selectRandom [
        "AmovPercMsprSlowWrflDf_AmovPpneMstpSrasWrflDnon",
        "AmovPercMevaSrasWrflDf_AmovPknlMstpSrasWrflDnon",
        "AmovPercMevaSrasWrflDfl_AmovPknlMstpSrasWrflDnon",
        "AmovPercMevaSrasWrflDfr_AmovPknlMstpSrasWrflDnon"
    ];
    _this setVariable ["lambs_danger_dangerDisabled",nil];
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
    if (_handle != (_group getVariable ["lambs_danger_forcedMovement",-1])) exitWith {};
    _unit forceSpeed -1;
    _unit setUnitPos "AUTO";
    _unit doFollow leader _unit;
    systemchat (name _unit);
};

// execute assault
private _handle = [
    {
        params ["_arg","_handle"];
        _arg params ["_group","_pos","_threshold","_units","_fnc_reached","_fnc_restore"];

        arrow1 setpos _pos;

        // move
        //_units doMove _pos;
        systemchat format ["handle %1 - units list %2 - time %3s",_handle,_units,round time];

        // Update units
        {
            // move
            _x doMove _pos;

            // clear targets ~ forget all targets. Harsh, but effective. - nkenny
            if (currentCommand _x isEqualTO "ATTACK") then {

                // two options
                // this generally works better. How then to sort out current assigned target of unit :/
                _x forgetTarget player;
                
                // another option -nkenny
                //[_x] joinSilent grpNull;
                //[_x] joinSilent _group;
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
            _group setVariable ["lambs_danger_forcedMovement",-1];
            _group setBehaviour "AWARE";
        };
    }, _cycle, [_group, _pos, _threshold, _units, _fnc_reached, _fnc_restore]
] call CBA_fnc_addPerFrameHandler;

// handle
_group setVariable ["lambs_danger_forcedMovement",_handle];

// end
true

/*
// Function ~ execute assault
private _fn_assault = {

    // init
    params ["_group","_pos","_units","_override","_fn_assault","_fnc_restore"];

    private _random = selectRandom _units;

    // movement
    _random doMove _pos;

    // execute reached position!
    if (_random distance _pos < 6) then {
        {
            _x playMoveNow selectRandom [
                "AmovPercMsprSlowWrflDf_AmovPpneMstpSrasWrflDnon",
                "AmovPercMevaSrasWrflDf_AmovPknlMstpSrasWrflDnon",
                "AmovPercMevaSrasWrflDfl_AmovPknlMstpSrasWrflDnon",
                "AmovPercMevaSrasWrflDfr_AmovPknlMstpSrasWrflDnon"
            ];
            _x setUnitPos "DOWN";
            //_x doMove getposASL _x;
            [_fnc_restore, _x, 6 + random 6] call CBA_fnc_waitAndExecute;

            // end
            _override = true;

        } foreach _units;
    };

    // Recursive execution
    if (count _units > 0 && {!_override}) then {
        [_fn_assault, [_group,_pos,_units,_override,_fn_assault,_fnc_restore], 1.2] call CBA_fnc_waitAndExecute;
    };
};

// execute
[_group,_pos,units _group,false,_fn_assault,_fnc_restore] call _fn_assault;

*/

// end
//true







// store
/*
private ["_behaviour","_formation","_speedMode","_combatMode","_attack"];
_behaviour = behaviour leader _group;
_formation = formation _group;
_speedMode = speedMode _group;
_combatMode = combatMode _group;
_attack = attackEnabled leader _group;

// orders

_group setBehaviourStrong "CARELESS";
_group setFormation "FILE";
_group setSpeedMode "FULL";
_group setCombatMode "GREEN";
_group enableAttack false;
*/

/*
// reset
_group setVariable ["lambs_danger_forcedMovement",false];
_group setBehaviour _behaviour;
_group setFormation _formation;
_group setSpeedMode _speedMode;
_group setCombatMode _combatMode;
_group enableAttack _attack;
*/
// reset units
