#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for extended suppressive fire towards buildings or location
 *
 * Arguments:
 * 0: group executing tactics <GROUP> or group leader <UNIT>
 * 1: group threat unit <OBJECT> or position <ARRAY>
 * 2: units in group, default all <ARRAY>
 * 3: delay until group is ready <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_tacticsSuppress;
 *
 * Public: No
*/
params ["_group", "_target", ["_units", []], ["_delay", 45]];

// group is missing
if (isNull _group) exitWith {false};

// get leader
if (_group isEqualType objNull) then {_group = group _group;};
if ((units _group) isEqualTo []) exitWith {false};
private _unit = leader _group;

// find target
_target = _target call CBA_fnc_getPos;
if ((_target select 2) > 6) then {
    _target set [2, 0.5];
};

// exit with flank squad leader cannot suppress from here
if !([_unit, (ATLToASL _target) vectorAdd [0, 0, 5]] call EFUNC(main,shouldSuppressPosition)) exitWith {
    [_group, _target] call FUNC(tacticsFlank);
};

// reset tactics
_group setVariable [QGVAR(isExecutingTactic), true];
[
    {
        params [["_group", grpNull], ["_delay", 0]];
        time > _delay || {isNull _group} || { !(_group getVariable [QGVAR(isExecutingTactic), false]) }
    },
    {
        params ["_group", "", ["_enableAttack", false], ["_formation", "WEDGE"]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QEGVAR(main,currentTactic), nil];
            _group enableAttack _enableAttack;
            {
                _x setVariable [QEGVAR(main,currentTask), nil, EGVAR(main,debug_functions)];
                _x doFollow (leader _x);
            } forEach (units _group);
        };
    },
    [group _unit, time + _delay, attackEnabled _unit, formation _group]
] call CBA_fnc_waitUntilAndExecute;

// alive unit
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

// find units
if (_units isEqualTo []) then {
    _units = _unit call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// find vehicles with weapons
private _vehicles = ([_unit] call EFUNC(main,findReadyVehicles)) select {someAmmo _x};

// sort building locations
private _postList = [_target, 20, true, false] call EFUNC(main,findBuildings);
_postList append ((nearestTerrainObjects [ _target, ["HIDE", "TREE", "BUSH", "SMALL TREE"], 8, false, true]) apply { (getPosATL _x) vectorAdd [0, 0, random 2] });
_postList pushBack _target;

// set tasks
_unit setVariable [QEGVAR(main,currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Leader Suppress", EGVAR(main,debug_functions)];

// set group task
_group = group _unit;
_group enableAttack false;
_group setFormation "LINE";
_group setVariable [QEGVAR(main,currentTactic), "Suppressing", EGVAR(main,debug_functions)];

// gesture
[_unit, "gesturePoint"] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "SuppressiveFire", 125] call EFUNC(main,doCallout);

// ready group
_group setFormDir (_unit getDir _target);

// execute recursive cycle
 [{_this call EFUNC(main,doGroupSuppress)}, [_group, _units, _vehicles, _postList], 1 + random 1] call CBA_fnc_waitAndExecute;

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS SUPPRESS (%2 with %3 units and %6 vehicles @ %4m with %5 positions)", side _unit, name _unit, count _units, round (_unit distance2D _target), count _postList, count _vehicles] call EFUNC(main,debugLog);
    private _m = [_unit, "tactics suppress", _unit call EFUNC(main,debugMarkerColor), "hd_arrow"] call EFUNC(main,dotMarker);
    private _mt = [_target, "", _unit call EFUNC(main,debugMarkerColor), "hd_destroy"] call EFUNC(main,dotMarker);
    {_x setMarkerSizeLocal [0.6, 0.6];} forEach [_m, _mt];
    _m setMarkerDirLocal (_unit getDir _target);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
