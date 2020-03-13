#include "script_component.hpp"
/*
 * Author: nkenny
 * Creep up close
 *        Unit creeps up as close as possible before opening fire.
 *        Stance is based on distance
 *        Speed is always limited
 *        Hold fire for as long as possible.
 *
 * Arguments:
 * 0: Group performing action, either unit <OBJECT> or group <GROUP>
 * 1: Range of tracking, default is 500 meters <NUMBER>
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, 500] spawn lambs_wp_fnc_taskCreep;
 *
 * Public: No
*/

if !(canSuspend) exitWith {
    _this spawn FUNC(taskCreep);
};

// functions ---

private _fnc_creepOrders = {
    params ["_group", "_target"];

    // distance
    private _newDist = (leader _group) distance2d _target;
    private _in_forest = ((selectBestPlaces [getpos (leader _group), 2, "(forest + trees)/2", 1, 1]) select 0) select 1;

    // danger mode? go for it!
    if (behaviour (leader _group) isEqualTo "COMBAT") exitWith {
        _group setCombatMode "RED";
        {
            _x setUnitpos "MIDDLE";
            _x domove (getPosATL _target);
            true
        } count (units _group);
    };

    // vehicle? wait for it
    if (_newDist < 150 && {vehicle _target isKindOf "Landvehicle"}) exitWith {
        _group reveal _target;
        { _x setUnitPos "DOWN"; true } count (units _group);
    };

    // adjust behaviour
    if (_in_forest > 0.9 || _newDist > 200) then { { _x setUnitPos "UP"; true} count (units _group); };
    if (_in_forest < 0.6 || _newDist < 100) then { { _x setUnitPos "MIDDLE"; true} count (units _group); };
    if (_in_forest < 0.4 || _newDist < 50) then { { _x setUnitPos "DOWN"; true} count (units _group); };
    if (_newDist < 40) exitWith { _group setCombatMode "RED"; _group setBehaviour "STEALTH"; };

    // move
    private _i = 0;
    {
        _x doMove (_target getPos [_i, random 360]);
        _i = _i + random 10;
        true
    } count (units _group);
};


// functions end ---

// init
params ["_group", ["_radius", 500], ["_cycle", 15], ["_area", [], [[]]], ["_pos", [], [[]]]];

// sort grp
if (!local _group) exitWith {false};
if (_group isEqualType objNull) then { _group = group _group; };

// orders
_group setBehaviour "AWARE";
_group setFormation "WEDGE";    //Might revert to DIAMOND
_group setSpeedMode "LIMITED";
_group setCombatMode "GREEN";
_group enableAttack false;
///{_x forceWalk true;} foreach units _group;  <-- Use this if behaviour set to "STEALTH"

// failsafe!
{
    //doStop _x;
    _x addEventhandler ["FiredNear", {
        params ["_unit"];
        _unit setCombatMode "RED";
        (group _unit) enableAttack true;
        _unit removeEventHandler ["FiredNear", _thisEventHandler];
    }];
    true
} count units _group;

// creep loop
waitUntil {

    // performance
    waitUntil {sleep 1; simulationenabled leader _group};

    // find
    private _target = [_group, _radius, _area, _pos] call FUNC(findClosestTarget);

    // act
    if (!isNull _target) then {
        [_group, _target] call _fnc_creepOrders;
        if (EGVAR(danger,debug_functions)) exitWith {format ["%1 taskCreep: %2 targets %3 (%4) at %5 Meters -- Stealth %6/%7", side _group, groupID _group, name _target, _group knowsAbout _target, floor (leader _group distance2d _target), ((selectBestPlaces [getpos leader _group, 2, "(forest + trees)/2", 1, 1]) select 0) select 1, str(unitPos leader _group)] call EFUNC(danger,debugLog);};
        _cycle = 30;
    } else {
        _cycle = 120;
        _group setCombatMode "GREEN"
    };

    // delay and end
    sleep _cycle;
    ((units _group) findIf {_x call EFUNC(danger,isAlive)} == -1)
};

// end
true
