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
 * 4: Area the AI Camps in, default [] <ARRAY>
 * 5: Is Called for Waypoint, default false <BOOL>
 *
 * Return Value:
 * none
 *
 * Example:
 * [bob, getPos angryJoe, 50] spawn lambs_wp_fnc_taskCQB;
 *
 * Public: Yes
*/

if !(canSuspend) exitWith {
    _this spawn FUNC(taskCQB);
};
// init
params [
    ["_group", grpNull, [grpNull, objNull]],
    ["_pos", [0, 0, 0]],
    ["_radius", TASK_CQB_SIZE, [0]],
    ["_cycle", TASK_CQB_CYCLETIME, [0]],
    ["_area", [], [[]]],
    ["_useWaypoint", false, [false]]
];

// functions ---

// find buildings
private _fnc_find = {
    params ["_pos", "_radius", "_group", ["_area", [], [[]]]];
    private _building = nearestObjects [_pos, ["house", "strategic", "ruins"], _radius, true];
    _building = _building select {!((_x buildingPos -1) isEqualTo [])};
    _building = _building select {count (_x getVariable [format ["%1_%2", QEGVAR(danger,CQB_cleared), str (side _group)], [0, 0]]) > 0};

    if !(_area isEqualTo []) then {
        _area params ["_a", "_b", "_angle", "_isRectangle", ["_c", -1]];
        _building = _building select { (getPos _x) inArea [_pos, _a, _b, _angle, _isRectangle, _c] };
    };

    if (_building isEqualTo []) exitWith { objNull };

    private _nearestBuildings = _building apply {[(leader _group) distance2D _x, _x]}; // sort nearest -nkenny
    _nearestBuildings sort true;
    (_nearestBuildings param [0, [0, objNull]]) param [1, objNull]
};

// check for enemies
private _fnc_enemy = {
    params ["_building", "_group"];
    private _pos = [ getPos _building, getPos leader _group] select isNull _building;
    private _enemy = (leader _group) findNearestEnemy _pos;
    if (isNull _enemy || {_pos distance2d _enemy < 25}) exitWith { _enemy };
    objNull
};

// compile actions
private _fnc_act = {
    params ["_enemy", "_group", "_building"];

    // units
    private _units = (units _group) select {isNull objectParent _x && {_x call EFUNC(main,isAlive)}};

    // deal with close enemy
    if (!isNull _enemy) exitWith {

        // debug
        if (EGVAR(main,debug_functions)) then {
            format ["%1 taskCQB: RUSH ENEMY!",side _group] call EFUNC(main,debugLog);
            createSimpleObject ["Sign_Arrow_Large_F", getPosASL _enemy, true];
        };

        // posture
        doStop _units;
        [leader _group, ["gestureAttack", "gestureGo", "gestureGoB"]] call EFUNC(main,doGesture);

        // location
        private _buildingPos = ((nearestBuilding _enemy) buildingPos -1) select {_x distance _enemy < 5};
        _buildingPos pushBack (getPosATL _enemy);

        private _buildingPosSelected = selectRandom _buildingPos;

        // act
        {
            _x forceSpeed ([_x,_buildingPosSelected] call EFUNC(danger,assaultSpeed));
            _x doMove _buildingPosSelected;
            _x lookAt _enemy;

            // task
            _x setVariable [QEGVAR(danger,currentTarget), _buildingPosSelected, EGVAR(main,debug_functions)];
            _x setVariable [QEGVAR(danger,currentTask), "taskCQB - Rush enemy", EGVAR(main,debug_functions)];
            true
        } count _units;
    };

    // clear and check buildings
    private _buildingPos = _building getVariable [format["%1_%2", QEGVAR(danger,CQB_cleared), str (side _group)], (_building buildingPos -1) select {lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0, 0, 10]]}];
    {

        // this is the pos to clear!
        private _buildingPosSelected = _buildingPos param [0, []];

        // the assault
        if (!(_buildingPos isEqualTo []) && {unitReady _x}) then {
            _x setUnitPos "UP";
            _x forceSpeed ([_x,_buildingPosSelected] call EFUNC(danger,assaultSpeed));
            _x doMove (_buildingPosSelected vectorAdd [0.5 - random 1, 0.5 - random 1, 0]);

            // debug
            if (EGVAR(main,debug_functions)) then {
                private _arrow = createSimpleObject ["Sign_Arrow_Large_Blue_F", AGLtoASL _buildingPosSelected, true];
                _arrow setObjectTexture [0, [_x] call EFUNC(main,debugObjectColor)];
            };

            // task
            _x setVariable [QEGVAR(danger,currentTarget), _buildingPosSelected, EGVAR(main,debug_functions)];
            _x setVariable [QEGVAR(danger,currentTask), "taskCQB - Clearing rooms", EGVAR(main,debug_functions)];

            // clean list
            if (_x distance _buildingPosSelected < 30 || { RND(0.5) && {(leader _group isEqualTo _x)}}) then {
                _buildingPos deleteAt 0;
            } else {
                // teleport debug (unit sometimes gets stuck due to Arma buildings )
                if (RND(0.6) && {_x call EFUNC(main,isIndoor)} && {_x distance _buildingPosSelected > 45} && {!([_x, 50] call CBA_fnc_nearPlayer)}) then {
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
            if (unitReady _x && {!(_x call EFUNC(main,isIndoor))}) then {
                [_x, getPosASL _building] call EFUNC(danger,suppress);
                _x doFollow leader _x;
            };
        };
        true
    } count _units;

    // update variable
    _building setVariable [format["%1_%2", QEGVAR(danger,CQB_cleared), str (side _group)], _buildingPos];
};

// functions end ---

// sort grp
if (!local _group) exitWith {
    [QGVAR(taskCQB), _this, _group] call CBA_fnc_targetEvent;
};

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
waitUntil {

    // performance
    waitUntil {sleep 1; simulationEnabled (leader _group)};

    // get wp position
    private _wPos = _pos call CBA_fnc_getPos;

    // find building
    private _building = [_wPos, _radius, _group, _area] call _fnc_find;

    // find enemy
    private _enemy = [_building, _group] call _fnc_enemy;

    // act!
    if (isNull _building && {isNull _enemy}) exitWith {false};
    [_enemy, _group, _building] call _fnc_act;

    // debug
    if (EGVAR(main,debug_functions)) then {format ["%1 taskCQB: (team: %2) (units: %3) (enemies: %4)", side _group, groupID _group, count units _group, !isNull _enemy] call EFUNC(main,debugLog);}; // instead of boolean for enemies, would be better with a count -nkenny

    // wait
    sleep _cycle;

    // end
    ((units _group) findIf {_x call EFUNC(main,isAlive)} == -1)

};

// reset
{
    _x setVariable [QEGVAR(danger,disableAI), nil];
    _x setUnitpos "AUTO";
    _x doFollow (leader _x);
} foreach units _group;

// debug
if (EGVAR(main,debug_functions)) then {format ["%1 taskCQB: CQB DONE version 0.3", side _group] call EFUNC(main,debugLog);};

// end
true
