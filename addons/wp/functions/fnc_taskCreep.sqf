#include "script_component.hpp"
// Creep up close
// version 4.1
// by nkenny

/*
    ** WAYPOINT EDITION **

    Unit creeps up as close as possible before opening fire.
    Stance is based on distance
    Speed is always limited
    Hold fire for as long as possible.

    Arguments
        1, Group or object tracker  [Object or Group]
        2, Range of tracking        [Number]              <-- not for this version
*/

// functions ---

private _fn_findTarget = {
    _nd = _r;
    _all = (switchableUnits + playableUnits - entities "HeadlessClient_F");
    _t = objNull;
    {
        _d = (leader _grp) distance2d _x;
        if (_d < _nd && {side _x != civilian} && {side _x != side _grp} && {getpos _x select 2 < 200}) then {_t = _x;_nd = _d;};
        true
    } count _all;
    _t
};

private _fn_creepOrders = {
    // distance
    _nd = leader _grp distance2d _t;
    _in_forest = ((selectBestPlaces [getpos leader _grp, 2,"(forest + trees)/2", 1, 1]) select 0) select 1;

   // danger mode? go for it!
   if (behaviour leader _grp isEqualTo "COMBAT") exitWith {_grp setCombatMode "RED";{_x setUnitpos "MIDDLE";_x domove (getposATL _t);true} count units _grp;};

   // vehicle? wait for it
   if (_nd < 150 && {vehicle _t isKindOf "Landvehicle"}) exitWith {_grp reveal _t;{_x setunitpos "DOWN";true} count units _grp;};

   // adjust behaviour
   if (_in_forest > 0.9 || _nd > 200) then {{_x setUnitpos "UP";true} count units _grp};
   if (_in_forest < 0.6 || _nd < 100) then {{_x setUnitpos "MIDDLE";true} count units _grp};
   if (_in_forest < 0.4 || _nd < 50) then {{_x setUnitpos "DOWN";true} count units _grp};
   if (_nd < 40) exitWith {_grp setCombatMode "RED";_grp setbehaviour "STEALTH";};

   // move
   _i = 0;
   {
    _x doMove (_t getPos [_i,random 360]);
    _i = _i + random 10;
    true
   } count units _grp;
};

_fn_debug = {
    if !EGVAR(danger,debug_functions) exitWith {};
    systemchat format ["danger.wp taskCreep: %1 targets %2 (%3) at %4 Meters -- Stealth %5/%6",groupID _grp,name _t,_grp knowsAbout _t,floor (leader _grp distance2d _t),((selectBestPlaces [getpos leader _grp, 2,"(forest + trees)/2", 1, 1]) select 0) select 1,str(unitPos leader _grp)];
};


// functions end ---

// init
private _grp = param [0];
private _pos = param [1];
private _r = waypointCompletionRadius [_grp,currentwaypoint _grp];
private _cycle = 15;

// sort grp
if (!local _grp) exitWith {};
_grp = [_grp] call {if (typeName _grp == "OBJECT") exitWith {group _grp};_grp};

// wp fix
if (_r isEqualTo 0) then {_r = 500;};

// orders
_grp setbehaviour "AWARE";
_grp setFormation "DIAMOND";
_grp setSpeedMode "LIMITED";
_grp setCombatMode "GREEN";
_grp enableAttack false;
///{_x forceWalk true;} foreach units _grp;  <-- Use this if behaviour set to "STEALTH"

// failsafe!
{
  doStop _x;
  _x addEventhandler ["FiredNear",{
      params ["_unit"];
      doStop _x;
      _unit setCombatMode "RED";
      _unit suppressFor 4;
      group _unit enableAttack true;
      _unit removeEventHandler ["FiredNear",_thisEventHandler];
    }];
  true
} count units _grp;

// creep loop
while {{alive _x} count units _grp > 0} do {

    // performance
    waitUntil {sleep 1; simulationenabled leader _grp};

    // find
    _t = call _fn_findTarget;

    // act
    if (!isNull _t) then {
        call _fn_creepOrders;
        call _fn_debug;
        _cycle = 30;
    } else {
        _cycle = 120;
        _grp setCombatMode "GREEN"
    };

    // delay
    sleep _cycle;
};

// end
true
