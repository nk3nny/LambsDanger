#include "script_component.hpp"
// Aggressive Attacker script
// version 5.0
// by nkenny

/*
  ** WAYPOINT EDITION **

  Aggressive tracking and attacking script

  Arguments
    1, Group or object tracker  [Object or Group]
    2, position                 [Array]
    //2, Range of tracking      [Number]              <-- not for this version
*/

// functions ---

private _fnc_rushOrders = {
    params ["_group", "_target"];
    // Helicopters -- supress it!
    if (((leader _group) distance2d _target < 200) && {vehicle _target isKindOf "Air"}) exitWith {
        {
            _x commandSuppressiveFire getPosASL _target;
            true
        } count (units _group);
    };

    // Tank -- hide or ready AT
    if ((leader _group distance2d _target < 80) && {vehicle _target isKindOf "Tank"}) exitWith {
        {
            if (secondaryWeapon _x != "") then {
                _x setUnitPos "Middle";
                _x selectWeapon (secondaryweapon _x);
            } else {
                _x setUnitPos "DOWN";
                _x commandSuppressiveFire getPosASL _target;
            };
            true
        } count (units _group);
        _group enableGunLights "forceOff";
    };

    // Default -- run for it!
    { _x setUnitPos "UP"; _x doMove (getPosATL _target); true } count units _group;
    _group enableGunLights "forceOn";
};
// functions end ---

// init
params ["_group",["_radius",500]];
private _cycle = 15;

// sort grp
if (!local _group) exitWith {};
if (_group isEqualType objNull) then { _group = group _group; };

// orders
_group setSpeedMode "FULL";
_group setFormation "LINE";
_group enableAttack false;
{ _x disableAI "AUTOCOMBAT"; doStop _x; true } count units _group;

// Hunting loop
while {{alive _x} count units _group > 0} do {

    // performance
    waitUntil { sleep 1; simulationenabled leader _group; };

    // find
    private _target = [_group, _radius] call FUNC(findClosedTarget);

    // act
    if (!isNull _target) then  {
        [_group, _target] call _fnc_rushOrders;
        if (!EGVAR(danger,debug_functions)) then { systemchat format ["danger.wp taskRush: %1 targets %2 (%3) at %4 Meters", groupID _group, name _target, _group knowsAbout _target, floor (leader _group distance2d _target)]; };
        _cycle = 15;
    } else {
        _cycle = 60;
    };

    // delay
    sleep _cycle;
};

// end
true
