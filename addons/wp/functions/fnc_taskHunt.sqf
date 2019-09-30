#include "script_component.hpp"
// Tracker script
// version 3.6
// by nkenny

/*
    ** WAYPOINT EDITION **

    Slower more deliberate tracking and attacking script
    Spawns flares to coordinate

    Arguments
        1, Group or object tracker  [Object or Group]
        2, Range of tracking        [Number]              <-- not for this version
*/

// 1. FIND TRACKER
private _grp = param [0];
private _r = waypointCompletionRadius [_grp,currentwaypoint _grp];
private _cycle = 60 + random 30;

// sort grp
if (!local _grp) exitWith {};
_grp = [_grp] call {if (typeName _grp == "OBJECT") exitWith {group _grp};_grp};

// wp fix
if (_r isEqualTo 0) then {_r = 500;};

// 2. SET GROUP BEHAVIOR
_grp setbehaviour "SAFE";
_grp setSpeedMode "LIMITED";

// FUNCTIONS -------------------------------------------------------------

// FLARE SCRIPT
private _fn_flare = {
    _shootflare = "F_20mm_Red" createvehicle ((leader _grp) ModelToWorld [0,0,200]);
    _shootflare setVelocity [0,0,-10];
};

// FIND TARGET
private _fn_findTarget = {
    _nd = _r;
    _all = (switchableUnits + playableUnits - entities "HeadlessClient_F");
    _all = _all select {side _x != side _grp && {side _x != civilian}};
    _t = objNull;
    {
        _d = (leader _grp) distance2d _x;
        if (_d < _nd && {getposATL _x select 2 < 200}) then {_t = _x;_nd = _d;};
        true
    } count _all;
    _t
};

// 3. DO THE HUNT SCRIPT! ---------------------------------------------------
while {{alive _x} count units _grp > 0} do {

    // performance
    waitUntil {sleep 1;simulationenabled leader _grp};

    // find
    _t = call _fn_findTarget;

    // settings
    _combat = behaviour leader _grp isEqualTo "COMBAT";
    _onFoot = (isNull objectParent (leader _grp));

    // GIVE ORDERS  ~~ Or double wait
    if (!isNull _t) then  {
        _grp move (_t getPos [random 100,random 360]);
        _grp setFormDir (leader _grp getDir _t);
        _grp setSpeedMode "NORMAL";
        _grp enableGunLights "forceOn";
        _grp enableIRLasers true;

        // DEBUG
        if (EGVAR(danger,debug_functions)) then {systemchat format ["danger.wp taskHunt: %1 targets %2 at %3 Meters",_grp,name _t,floor (leader _grp distance _t)]};

        // FLARE HERE
        if (!_combat && {_onFoot} && {random 1 > 0.8}) then {[] call _fn_flare};

        // BUILDING SUPPRESSION!  <-- should be unecessary in danger.fsm
        //if (_combat && {(nearestBuilding _t distance2d _t < 25)}) then {{_x doSuppressiveFire ((getposASL _t) vectorAdd [random 2,random 2,0.5 + random 3]);true} count units _grp;};
    };

    // WAIT FOR IT!
    sleep _cycle;
};
