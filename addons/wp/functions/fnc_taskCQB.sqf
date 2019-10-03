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
private _fnc_find = {
    params ["_pos", "_range", "_grp"]
    private _building = nearestObjects [_pos, ["house","strategic","ruins"], _range, true];
    _building = _building select {count (_x buildingPos -1) > 0};
    _building = _building select {count (_x getVariable ["LAMBS_CQB_cleared_" + str (side _grp), [0, 0]]) > 0};
    if (count _building > 0) exitWith { _building select 0 };
    objNull
};

// check for enemies
private _fnc_enemy = {
    params ["_building", "_grp"];
    private _pos = if (isNull _building) then { getPos (leader _grp) } else { getpos _building };
    private _enemy = (leader _grp) findNearestEnemy _pos;
    if (isNull _enemy || {_pos distance2d _enemy < 25}) exitWith {_enemy};
    (leader _grp) doSuppressiveFire _enemy;
    objNull
};

// compile actions
private _fnc_act = {
    params ["_enemy", "_grp"];
    // deal with close enemy
    if (!isNull _enemy) exitWith {

        // debug
        if (EGVAR(danger,debug_functions)) then {
            systemchat "danger.wp taskCQB: RUSH ENEMY!";
            createVehicle ["Sign_Arrow_Large_F", getposATL _enemy, [],0,"CAN_COLLIDE"];
        };

        // posture
        doStop (units _grp);
        (leader _grp) playAction selectRandom ["gestureAttack","gestureGo","gestureGoB"];

        // location
        private _buildingPos = ((nearestBuilding _enemy) buildingPos -1) select {_x distance _enemy < 5};
        _buildingPos pushBack (getPosATL _enemy);

        // act
        {
            _x doMove selectRandom _buildingPos;
            _x doWatch _enemy;
            true
        } count units _grp;
    };

    // clear and check buildings
    private _buildingPos = _building getVariable ["LAMBS_CQB_cleared_" + str (side _grp),(_buildingbuildingPos -1) select {lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0,0,10]]}];
    //_buildingPos = _buildinggetVariable ["nk_CQB_cleared",(_buildingbuildingPos -1)];
    {
        // the assault
        if ((count _buildingPos > 0) && {unitReady _x}) then {
            _x setUnitPos "UP";
            _x doMove ((_buildingPos select 0) vectorAdd [0.5 - random 1,0.5 - random 1,0]);

            // debug
            if (EGVAR(danger,debug_functions)) then {
                createVehicle ["Sign_Arrow_Large_Blue_F", _buildingPos select 0, [], 0, "CAN_COLLIDE"];
            };

            // clean list
            if (_x distance (_buildingPos select 0) < 30 || {(leader _grp isEqualTo _x) && {random 1 > 0.5}}) then {
                _buildingPos deleteAt 0;
            } else {
                // teleport debug (unit sometimes gets stuck due to Arma buildings )
                if (lineIntersects [eyePos _x, (eyePos _x) vectorAdd [0,0,10]] && {_x distance (_buildingPos select 0) > 45} && {random 1 > 0.6}) then {
                    _x setVehiclePosition [getPos _x, [], 3.5];
                };

                // distance to building is too far?
                //if (_x distance (_buildingPos select 0) > 100) then {
                //  _x doMove (_buildinggetPos [-10,(_x getDir _b)]);
                //};
            };
        } else {

            // visualisation -- unit is either busy or too far to be effective
            _x setUnitPos "MIDDLE";

            // Unit is ready and outside -- try suppressive fire
            if (unitReady _x && {!(lineIntersects [eyePos _x, (eyePos _x) vectorAdd [0, 0, 10]])}) then {
                _x doSuppressiveFire _building;
                _x doFollow (leader _grp);
            };
        };
        true
    } count units _grp;

    // update variable
    _building setVariable ["LAMBS_CQB_cleared_" + str (side _grp), _buildingPos];
};

// functions end ---

// init
params ["_grp", "_pos"];
private _radius = waypointCompletionRadius [_grp, currentwaypoint _grp];
private _cycle = 21;

// sort grp
if (!local _grp) exitWith {};
if (_grp isEqualType objNull) then {
    _grp = group _grp;
}

// wp fix
if (_radius isEqualTo 0) then {_radius = 50;};

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
    _building = [_pos, _range, _grp] call _fnc_find;

    // find enemy
    _enemy = [_building, _grp] call _fnc_enemy;

    // act!
    if (isNull _building&& {isNull _e}) exitWith {};
    [_enemy, _grp] call _fnc_act;

    // wait
    sleep _cycle;
    if (EGVAR(danger,debug_functions)) then {systemchat format ["danger.wp taskCQB: (team: %1) (units: %2) (enemies: %3)", groupID _grp, count units _grp, !isNull _e];};

};

// reset
if (EGVAR(danger,debug_functions)) then {systemchat "danger.wp taskCQB: CQB DONE version 0.27";};

// end
true
