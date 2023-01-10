#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for extended aggressive assault towards buildings or location
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: group threat unit <OBJECT> or position <ARRAY>
 * 2: units in group, default all <ARRAY>
 * 3: how many assault cycles <NUMBER>
 * 4: delay until unit is ready again <NUMBER>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_tacticsAssault;
 *
 * Public: No
*/
params ["_unit", "_target", ["_units", []], ["_cycle", 16], ["_delay", 70]];

// find target
_target = _target call CBA_fnc_getPos;
private _group = group _unit;

// reset tactics
[
    {
        params [["_group", grpNull], ["_enableAttack", true], ["_isIRLaserOn", false], ["_speedMode", "NORMAL"], ["_formation", "WEDGE"], ["_combatMode", "YELLOW"]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QEGVAR(main,currentTactic), nil];
            _group enableAttack _enableAttack;
            _group enableIRLasers _isIRLaserOn;
            _group setSpeedMode _speedMode;
            _group setFormation _formation;
            _group setCombatMode _combatMode;
            {
                _x setVariable [QGVAR(forceMove), nil];
                _x setVariable [QEGVAR(main,currentTask), nil, EGVAR(main,debug_functions)];
                _x doFollow leader _x;
                _x forceSpeed -1;
            } foreach (units _group);
        };
    },
    [_group, attackEnabled _group, _unit isIRLaserOn (currentWeapon _unit), speedMode _group, formation _group, combatMode _group],
    _delay
] call CBA_fnc_waitAndExecute;

// alive unit
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

// set speed and enableAttack
_group enableAttack false;
_group setSpeedMode "FULL";
_group setFormation "LINE";
_group setCombatMode "YELLOW";

// find units
if (_units isEqualTo []) then {
    _units = [_unit, 250] call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// sort potential targets
private _buildings = [_target, 28, false, false] call EFUNC(main,findBuildings);
_buildings = _buildings apply { [_unit distanceSqr _x, _x] };
_buildings sort true;
_buildings = _buildings apply { _x select 1 };
private _housePos = [];
{
    _housePos append (_x buildingPos -1);
} foreach _buildings;

// add building positions to group memory
_group setVariable [QEGVAR(main,groupMemory), _housePos];

// add base position
_housePos pushBack _target;

// set tasks
_unit setVariable [QEGVAR(main,currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Tactics Assault", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QEGVAR(main,currentTactic), "Assaulting", EGVAR(main,debug_functions)];

// gesture
[_unit, "gestureGo"] call EFUNC(main,doGesture);
[_units select (count _units - 1), "gestureGoB"] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "Advance", 125] call EFUNC(main,doCallout);

// concealment
if (!GVAR(disableAutonomousSmokeGrenades)) then {

    // leader smoke
    [_unit, _target] call EFUNC(main,doSmoke);

    // grenadier smoke
    [{_this call EFUNC(main,doUGL)}, [_units, _target, "shotSmokeX"], 3] call CBA_fnc_waitAndExecute;
};

// ready group
_group setFormDir (_unit getDir _target);
_group enableIRLasers true;
_units doWatch objNull;

// check for reload
{
    reload _x;
} foreach (_units select {getSuppression _x < 0.7 && {needReload _x > 0.6}});

// execute function
[_cycle, _units, _housePos] call EFUNC(main,doGroupAssault);

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS ASSAULT (%2 with %3 units @ %4m with %5 buildings)", side _unit, name _unit, count _units, round (_unit distance2D _target), count _buildings] call EFUNC(main,debugLog);
    private _m = [_unit, "tactics assault", _unit call EFUNC(main,debugMarkerColor), "hd_arrow"] call EFUNC(main,dotMarker);
    private _mt = [_target, "", _unit call EFUNC(main,debugMarkerColor), "hd_join"] call EFUNC(main,dotMarker);
    {_x setMarkerSizeLocal [0.6, 0.6];} foreach [_m, _mt];
    _m setMarkerDirLocal (_unit getDir _target);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
