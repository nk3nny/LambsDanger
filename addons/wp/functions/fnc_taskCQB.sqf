#include "script_component.hpp"
/*
 * Author: nkenny
 * CQB script v0.28
 *        Group identifies buildings
 *        Clears them methodically
 *        marks building safe
 *        moves to next building
 *        repeat until no buildings left
 *
 * Arguments:
 * 0: Group performing action, either unit <OBJECT> or group <GROUP>
 * 1: Position targeted <ARRAY>
 * 2: Radius of search, default 50 <NUMBER>
 * 3: Delay of cycle, default 21 seconds <NUMBER>
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, getpos angryJoe, 50] call lambs_wp_fnc_taskCQB;
 *
 * Public: No
*/

if !(canSuspend) exitWith {
    _this spawn FUNC(taskCQB);
};

// functions ---

// find buildings
private _fnc_find = {
    params ["_pos", "_radius", "_group", ["_area", [], [[]]]];
    private _building = nearestObjects [_pos, ["house", "strategic", "ruins"], _radius, true];
    _building = _building select {count (_x buildingPos -1) > 0};
    _building = _building select {count (_x getVariable [QEGVAR(danger,CQB_cleared_) + str (side _group), [0, 0]]) > 0};

    if !(_area isEqualTo []) then {
        _area params ["_a", "_b", "_angle", "_isRectangle"];
        _building = _building select { (getPos _x) inArea [_pos, _a, _b, _angle, _isRectangle] };
    };

    if (_building isEqualTo []) exitWith { objNull };

    _building = _building apply {[_pos distance2D _x, _x]}; // sort nearest -nkenny
    _building sort true;
    (_building select 0) select 1
};

// check for enemies
private _fnc_enemy = {
    params ["_building", "_group"];
    private _pos = [ getpos _building, getpos leader _group] select isNull _building;
    private _enemy = (leader _group) findNearestEnemy _pos;
    if (isNull _enemy || {_pos distance2d _enemy < 25}) exitWith {_enemy};
    (leader _group) doSuppressiveFire _enemy;
    objNull
};

// compile actions
private _fnc_act = {
    params ["_enemy", "_group", "_building"];

    // units
    private _units = (units _group) select {isNull objectParent _x && {_x call EFUNC(danger,isAlive)}};

    // deal with close enemy
    if (!isNull _enemy) exitWith {

        // debug
        if (EGVAR(danger,debug_functions)) then {
            format ["%1 taskCQB: RUSH ENEMY!",side _group] call EFUNC(danger,debugLog);
            createSimpleObject ["Sign_Arrow_Large_F", getposASL _enemy, true];
        };

        // posture
        doStop _units;
        [leader _group, ["gestureAttack", "gestureGo", "gestureGoB"]] call EFUNC(danger,gesture);

        // location
        private _buildingPos = ((nearestBuilding _enemy) buildingPos -1) select {_x distance _enemy < 5};
        _buildingPos pushBack (getPosATL _enemy);

        private _buildingPosSelected = _buildingPos select 0;

        // act
        {
            _x forceSpeed ([_x,_buildingPosSelected] call EFUNC(danger,assaultSpeed));
            _x doMove selectRandom _buildingPos;
            _x lookAt _enemy;
            true
        } count _units;
    };

    // clear and check buildings
    private _buildingPos = _building getVariable [QEGVAR(danger,CQB_cleared_) + str (side _group), (_building buildingPos -1) select {lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0, 0, 10]]}];
    //_buildingPos = _buildinggetVariable ["nk_CQB_cleared", (_buildingbuildingPos -1)];
    {

        // this is the pos to clear!
        private _buildingPosSelected = _buildingPos select 0;

        // the assault
        if (!(_buildingPos isEqualTo []) && {unitReady _x}) then {
            _x setUnitPos "UP";
            _x forceSpeed ([_x,_buildingPosSelected] call EFUNC(danger,assaultSpeed));
            _x doMove (_buildingPosSelected vectorAdd [0.5 - random 1, 0.5 - random 1, 0]);

            // debug
            if (EGVAR(danger,debug_functions)) then {
                private _arrow = createSimpleObject ["Sign_Arrow_Large_Blue_F", AGLtoASL _buildingPosSelected, true];
                _arrow setObjectTexture [0, [_x] call EFUNC(danger,debugObjectColor)];
            };

            // task
            _x setVariable [QEGVAR(danger,currentTarget), _buildingPosSelected];
            _x setVariable [QEGVAR(danger,currentTask), "taskCQB - Clearing rooms"];

            // clean list
            if (_x distance _buildingPosSelected < 30 || { RND(0.5) && {(leader _group isEqualTo _x)}}) then {
                _buildingPos deleteAt 0;
            } else {
                // teleport debug (unit sometimes gets stuck due to Arma buildings )
                if (RND(0.6) && {_x call EFUNC(danger,indoor)} && {_x distance _buildingPosSelected > 45}) then {
                    _x setVehiclePosition [getPos _x, [], 3.5];
                };

                // distance to building is too far?
                //if (_x distance _buildingPosSelected > 100) then {
                //  _x doMove (_building getPos [-10, (_x getDir _b)]);
                //};
            };
        } else {

            // visualisation -- unit is either busy or too far to be effective
            _x setUnitPos "MIDDLE";

            // Unit is ready and outside -- try suppressive fire
            if (unitReady _x && {!(_x call EFUNC(danger,indoor))}) then {
                _x doSuppressiveFire _building;
                _x doFollow leader _x;
            };
        };
        true
    } count _units;

    // update variable
    _building setVariable [QEGVAR(danger,CQB_cleared_) + str (side _group), _buildingPos];
};

// functions end ---

// init
params ["_group", "_pos", ["_radius", 50], ["_cycle", 21], ["_area", [], [[]]], ["_useWaypoint", false]];


// sort grp
if (!local _group) exitWith {};
if (_group isEqualType objNull) then {
    _group = group _group;
};

// more dynamic pos
if (_useWaypoint) then {
    _pos = [_group ,(currentWaypoint _group) min ((count waypoints _group) - 1)];
};
// orders
_group setSpeedMode "FULL";
_group setFormation "FILE";
_group enableAttack false;
_group allowFleeing 0;
{
    _x setVariable [QEGVAR(danger,disableAI), true];
    _x disableAI "AUTOCOMBAT";
    _x disableAI "SUPPRESSION";
    _x enableIRLasers true;
    true
} count units _group;

// loop
while {{_x call EFUNC(danger,isAlive)} count units _group > 0} do {
    // performance
    waitUntil {sleep 1; simulationEnabled (leader _group)};

    // get wp position
    private _wPos = _pos call EFUNC(main,getPos);

    // find building
    private _building = [_wPos, _radius, _group, _area] call _fnc_find;

    // find enemy
    private _enemy = [_building, _group] call _fnc_enemy;

    // act!
    if (isNull _building && {isNull _enemy}) exitWith {};
    [_enemy, _group, _building] call _fnc_act;

    // wait
    sleep _cycle;
    if (EGVAR(danger,debug_functions)) then {format ["%1 taskCQB: (team: %2) (units: %3) (enemies: %4)", side _group, groupID _group, count units _group, !isNull _enemy] call EFUNC(danger,debugLog);}; // instead of boolean for enemies, would be better with a count -nkenny
};

// reset
{
    _x setVariable [QEGVAR(danger,disableAI), nil];
    _x setUnitpos "AUTO";
} foreach units _group;

// debug
if (EGVAR(danger,debug_functions)) then {format ["%1 taskCQB: CQB DONE version 0.29",side _group] call EFUNC(danger,debugLog);};

// end
true
