#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for extended aggressive assault towards buildings or location
 *
 * Arguments:
 * 0: group executing tactics <GROUP> or group leader <UNIT>
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
params ["_group", "_target", ["_units", []], ["_delay", 85]];

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

// reset tactics
[
    {
        params [["_group", grpNull], ["_enableAttack", true], ["_isIRLaserOn", false], ["_speedMode", "NORMAL"], ["_formation", "WEDGE"]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            _group setVariable [QEGVAR(main,currentTactic), nil];
            _group enableAttack _enableAttack;
            _group enableIRLasers _isIRLaserOn;
            _group setSpeedMode _speedMode;
            _group setFormation _formation;
            {
                _x setVariable [QEGVAR(main,currentTask), nil, EGVAR(main,debug_functions)];
                _x doFollow leader _x;
                _x forceSpeed -1;
            } forEach (units _group);
        };
    },
    [_group, attackEnabled _group, _unit isIRLaserOn (currentWeapon _unit), speedMode _group, formation _group],
    _delay
] call CBA_fnc_waitAndExecute;

// set speed and enableAttack
_group enableAttack false;
_group setSpeedMode "FULL";
_group setFormation (["LINE", "FILE"] select (((getPos _unit) getEnvSoundController "houses") > 0.9));;

// find units
if (_units isEqualTo []) then {
    _units = [_unit, 250] call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// sort potential targets
private _buildings = [_target, 28, true, true] call EFUNC(main,findBuildings);

// no buildings - populate with other things!
if (_buildings isEqualTo []) then {
    _buildings append ((nearestTerrainObjects [ _target, ["HIDE", "TREE", "BUSH", "SMALL TREE"], 8, false, true]) apply { (getPosATL _x) vectorAdd [2 - random 4, 2 - random 4, 2] });
    _buildings pushBack (_target vectorAdd [0, 0, 2]);
};

// more than 25 building positions. Reduce size!
if (count _buildings > 25) then {
    _buildings resize 25
};

// add building positions to group memory
_group setVariable [QEGVAR(main,groupMemory), _buildings];

// find vehicles
private _vehicles = [_unit] call EFUNC(main,findReadyVehicles);
private _overwatch = [ASLToAGL (getPosASL _unit), EGVAR(main,minSuppressionRange) * 2, EGVAR(main,minSuppressionRange), 4, _target, false] call EFUNC(main,findOverwatch);
if (_overwatch isNotEqualTo []) then {
    {
        private _roads = _overwatch nearRoads 30;
        if (_roads isNotEqualTo []) then {_overwatch = ASLToAGL (getPosASL (selectRandom _roads))};
        _x doMove _overwatch;
        _x doWatch (_target vectorAdd [0, 0, 2]);
    } forEach _vehicles;
};

// set tasks
_unit setVariable [QEGVAR(main,currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Tactics Assault", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QEGVAR(main,currentTactic), "Assaulting", EGVAR(main,debug_functions)];

// gesture
[_unit, "gestureGo"] call EFUNC(main,doGesture);
[_units select -1, "gestureGoB"] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", "Advance", 125] call EFUNC(main,doCallout);

// concealment
if (!GVAR(disableAutonomousSmokeGrenades)) then {

    // leader smoke
    [_unit, _target] call EFUNC(main,doSmoke);

    // grenadier smoke
    [{_this call EFUNC(main,doUGL)}, [_units, _target, "shotSmoke"], 3] call CBA_fnc_waitAndExecute;
};

// ready group
_group setFormDir (_unit getDir _target);
_group enableIRLasers true;
_units doWatch (_target vectorAdd [0, 0, 2]);
_units doMove ([_overwatch, _target] select (_overwatch isNotEqualTo []));

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS ASSAULT (%2 with %3 units @ %4m with %5 positions)", side _unit, name _unit, count _units, round (_unit distance2D _target), count _buildings] call EFUNC(main,debugLog);
    private _m = [_unit, "tactics assault", _unit call EFUNC(main,debugMarkerColor), "hd_arrow"] call EFUNC(main,dotMarker);
    private _mt = [_target, "", _unit call EFUNC(main,debugMarkerColor), "hd_join"] call EFUNC(main,dotMarker);
    {_x setMarkerSizeLocal [0.6, 0.6];} forEach [_m, _mt];
    _m setMarkerDirLocal (_unit getDir _target);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt], _delay + 30] call CBA_fnc_waitAndExecute;
};

// end
true
