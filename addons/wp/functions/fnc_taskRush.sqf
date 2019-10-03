#include "script_component.hpp"
// Aggressive Attacker script
// version 4.3
// by nkenny

/*
  ** WAYPOINT EDITION **

  Aggressive tracking and attacking script

  Arguments
    1, Group or object tracker  [Object or Group]
    2, position                 [Array]
    //2, Range of tracking        [Number]              <-- not for this version
*/

// functions ---

private _fnc_rushOrders = {
    params ["_grp", "_target"];
    // Helicopters -- supress it!
    if (((leader _grp) distance2d _target < 200) && {vehicle _target isKindOf "Air"}) exitWith {
        {
            _x commandSuppressiveFire (getPosASL _target);
            true
        } count (units _grp);
    };

    // Tank -- hide or ready AT
    if ((leader _grp distance2d _target < 80) && {vehicle _target isKindOf "Tank"}) exitWith {
        {
            if (secondaryWeapon _x != "") then {
                _x setUnitpos "Middle";
                _x selectWeapon (secondaryweapon _x);
            } else {
                _x setUnitPos "DOWN";
                _x commandSuppressiveFire getPosASL _target;
            };
            true
        } count (units _grp);
        _grp enableGunLights "forceOff";
    };

    // Default -- run for it!
    {_x setUnitPos "UP";_x doMove (getPosATL _t);true} count units _grp;
    _grp enableGunLights "forceOn";
};
// functions end ---

// init
params ["_grp", "_pos"];
private _radius = waypointCompletionRadius [_grp, currentwaypoint _grp];
private _cycle = 15;

// sort grp
if (!local _grp) exitWith {};
    if (_grp isEqualType objNull) then {
        _grp = group _grp;
    };

// wp fix
if (_radius isEqualTo 0) then {_radius = 500;};

// orders
_grp setSpeedMode "FULL";
_grp setFormation "DIAMOND";
_grp enableAttack false;
{_x disableAI "AUTOCOMBAT"; doStop _x; true} count units _grp;

// Hunting loop
while {{alive _x} count units _grp > 0} do {

    // performance
    waitUntil {sleep 1; simulationenabled leader _grp};

    // find
    private _target = [_grp, _radius] call FUNC(findClosedTarget);

    // act
    if (!isNull _target) then  {
        [_grp, _target] call _fnc_rushOrders;
        if (!EGVAR(danger,debug_functions)) then { systemchat format ["danger.wp taskRush: %1 targets %2 (%3) at %4 Meters", groupID _grp, name _target, _grp knowsAbout _target, floor (leader _grp distance2d _target)]; };
        _cycle = 15;
    } else {
        _cycle = 60;
    };

    // delay
    sleep _cycle;
};

// end
true
