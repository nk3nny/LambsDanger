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

private _fn_findTarget = {
    _nd = _r;
    _all = (switchableUnits + playableUnits - entities "HeadlessClient_F");
    _t = objNull;
    {
        //_d = (leader _grp) distance2d _x;
        _d = _pos distance2d _x;
        if (_d < _nd && {side _x != civilian} && {side _x != side _grp} && {getpos _x select 2 < 200}) then {_t = _x;_nd = _d;};
        true
    } count _all;
    _t
};

private _fn_rushOrders = {
    // Helicopters -- supress it!
    if ((leader _grp distance2d _t < 200) && {vehicle _t isKindOf "Air"}) exitWith {
        {
            _x commandSuppressiveFire getposASL _t;
            true
        } count units _grp;
    };

    // Tank -- hide or ready AT
    if ((leader _grp distance2d _t < 80) && {vehicle _t isKindOf "Tank"}) exitWith {
        {
            if (secondaryWeapon _x != "") then {
                _x setUnitpos "Middle";
                _x selectWeapon (secondaryweapon _x);
            } else {
                _x setUnitPos "DOWN";
                _x commandSuppressiveFire getposASL _t;
            };
            true
        } count units _grp;
        _grp enableGunLights "forceOff";
    };

    // Default -- run for it!
    {_x setunitpos "UP";_x domove (getposATL _t);true} count units _grp;
    _grp enableGunLights "forceOn";
};

private _fn_debug = {
    if (!EGVAR(danger,debug_functions)) exitWith {};
    systemchat format ["danger.wp taskRush: %1 targets %2 (%3) at %4 Meters",groupID _grp,name _t,_grp knowsAbout _t,floor (leader _grp distance2d _t)];
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
_grp setSpeedMode "FULL";
_grp setFormation "DIAMOND";
_grp enableAttack false;
{_x disableAI "AUTOCOMBAT";dostop _x;true} count units _grp;

// Hunting loop
while {{alive _x} count units _grp > 0} do {

    // performance
    waitUntil {sleep 1; simulationenabled leader _grp};

    // find
    _t = call _fn_findTarget;

    // act
    if (!isNull _t) then  {
        call _fn_rushOrders;
        call _fn_debug;
        _cycle = 15;
    } else {
        _cycle = 60;
    };

    // delay
    sleep _cycle;
};

// end
true
