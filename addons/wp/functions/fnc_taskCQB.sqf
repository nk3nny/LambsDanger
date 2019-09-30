#include "script_component.hpp"
// CQB script
// version 0.27
// by nkenny

/*
    ** WAYPOINT EDITION **

    Design
        Group identifies buildings
        Clears them methodically
        marks building safe
        moves to next building
        repeat until no buildings left
*/

// functions ---

// find buildings
private _fn_find = {
    _b = nearestobjects [_pos,["house","strategic","ruins"],_r,true];
    _b = _b select {count (_x buildingPos -1) > 0};
    _b = _b select {count (_x getVariable ["LAMBS_CQB_cleared_" + str (side _grp),[0,0]]) > 0};
    if (count _b > 0) exitWith {_b select 0};
    ObjNull
};

// check for enemies
private _fn_enemy = {
    private _p = if (isNull _b) then {getpos leader _grp} else {getpos _b};
    _e = (leader _grp) findNearestEnemy _p;
    if (isNull _e || {_p distance2d _e < 25}) exitWith {_e};
    leader _grp doSuppressiveFire _e;
    ObjNull
};

// compile actions
private _fn_act = {
    // deal with close enemy
    if (!isNull _e) exitWith {

        // debug
        if (EGVAR(danger,debug_functions)) then {
            systemchat "danger.wp taskCQB: RUSH ENEMY!";
            _veh = createVehicle ["Sign_Arrow_Large_F",getposATL _e,[],0,"CAN_COLLIDE"];
        };

        // posture
        doStop units _grp;
        leader _grp playAction selectRandom ["gestureAttack","gestureGo","gestureGoB"];

        // location
        _bp = ((nearestBuilding _e) buildingPos -1) select {_x distance _e < 5};
        _bp pushBack getPosATL _e;

        // act
        { _x doMove selectRandom _bp; _x doWatch _e; true } count units _grp;
    };

    // clear and check buildings
    _bp = _b getVariable ["LAMBS_CQB_cleared_" + str (side _grp),(_b buildingPos -1) select {lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0,0,10]]}];
    //_bp = _b getVariable ["nk_CQB_cleared",(_b buildingPos -1)];
    {
        // the assault
        if ((count _bp > 0) && {unitReady _x}) then {
            _x setUnitPos "UP";
            _x doMove ((_bp select 0) vectorAdd [0.5 - random 1,0.5 - random 1,0]);

            // debug
            if (EGVAR(danger,debug_functions)) then {
                _veh = createVehicle ["Sign_Arrow_Large_Blue_F",_bp select 0,[],0,"CAN_COLLIDE"];
            };

            // clean list
            if (_x distance (_bp select 0) < 30 || {(leader _grp isEqualTo _x) && {random 1 > 0.5}}) then {
                _bp deleteAt 0;
            } else {
                // teleport debug (unit sometimes gets stuck due to Arma buildings )
                if (lineIntersects [eyePos _x, (eyePos _x) vectorAdd [0,0,10]] && {_x distance (_bp select 0) > 45} && {random 1 > 0.6}) then {
                    _x setVehiclePosition [getPos _x, [], 3.5];
                };

                // distance to building is too far?
                //if (_x distance (_bp select 0) > 100) then {
                //  _x doMove (_b getPos [-10,(_x getDir _b)]);
                //};
            };
        } else {

            // visualisation -- unit is either busy or too far to be effective
            _x setUnitPos "MIDDLE";

            // Unit is ready and outside -- try suppressive fire
            if (unitReady _x && {!(lineIntersects [eyePos _x, (eyePos _x) vectorAdd [0,0,10]])}) then {
                _x doSuppressiveFire _b;
                _x doFollow leader _grp;
            };
        };
        true
    } count units _grp;

    // update variable
    _b setVariable ["LAMBS_CQB_cleared_" + str (side _grp),_bp];
};

// functions end ---

// init
private _grp = param [0];
private _pos = param [1];
private _r = waypointCompletionRadius [_grp,currentwaypoint _grp];
private _cycle = 21;

// sort grp
if (!local _grp) exitWith {};
_grp = [_grp] call {if (typeName _grp == "OBJECT") exitWith {group _grp};_grp};

// wp fix
if (_r isEqualTo 0) then {_r = 50;};

// orders
_grp setSpeedMode "FULL";
_grp setFormation "FILE";
_grp enableAttack false;
_grp allowFleeing 0;
{
    _x disableAI "AUTOCOMBAT";
    _x disableAI "SUPPRESSION";
    _x enableIRLasers true;
    true
} count units _grp;

// loop
while {{alive _x} count units _grp > 0} do {
    // performance
    waitUntil {sleep 1; simulationenabled leader _grp};

    // find building
    _b = call _fn_find;

    // find enemy
    _e = call _fn_enemy;

    // act!
    if (isNull _b && {isNull _e}) exitWith {};
    call _fn_act;

    // wait
    sleep _cycle;
    if (EGVAR(danger,debug_functions)) then {systemchat format ["danger.wp taskCQB: (team: %1) (units: %2) (enemies: %3)",groupID _grp,count units _grp,!isNull _e];};

};

// reset
if (EGVAR(danger,debug_functions)) then {systemchat "danger.wp taskCQB: CQB DONE version 0.27";};

// end
true
