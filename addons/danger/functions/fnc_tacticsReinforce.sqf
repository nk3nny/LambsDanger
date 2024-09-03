#include "script_component.hpp"
/*
 * Author: nkenny
 * Group reinforces a call for help!
 *
 * Arguments:
 * 0: group leader <OBJECT>
 * 1: group target <OBJECT> or position <ARRAY>
 * 2: units in group, default all <ARRAY>
 * 3: delay until unit is ready again <NUMBER>
 *
 * Return Value:
 * Bool
 *
 * Example:
 * [bob, getPos angryBob] call lambs_danger_fnc_tacticsReinforce;
 *
 * Public: No
*/
params ["_unit", ["_target", []], ["_units", []], ["_delay", 300]];

// exit on dead leader
if (!(_unit call EFUNC(main,isAlive))) exitWith {false};

// free garrisons
private _group = group _unit;
if (EGVAR(main,Loaded_WP) && {!(_unit checkAIFeature "PATH")}) then {
    _group = [_group, true, true] call EFUNC(wp,taskReset);
};

// set new time
_group setVariable [QGVAR(enableGroupReinforce), true, true];
_group setVariable [QGVAR(enableGroupReinforceTime), time + _delay, true];

// set tasks
_target = _target call CBA_fnc_getPos;
_unit setVariable [QEGVAR(main,currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Reinforce", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QEGVAR(main,currentTactic), "Reinforcing", EGVAR(main,debug_functions)];
_group setVariable [QGVAR(isExecutingTactic), true];
_group setVariable [QGVAR(contact), time + _delay];
_group enableAttack false;      // gives better fine control of AI - nkenny
_group setBehaviour "AWARE";    // more tractable speed

// reset
[
    {
        params [["_group", grpNull, [grpNull]]];
        if (!isNull _group) then {
            _group setVariable [QGVAR(isExecutingTactic), nil];
            private _leader = leader _group;
            if !(isNull objectParent _leader) then {(vehicle _leader) setUnloadInCombat [true, false];};
        };
    },
    _group,
    _delay * 0.5
] call CBA_fnc_waitAndExecute;

// eventhandler
[QGVAR(OnReinforce), [_unit, group _unit, _target]] call EFUNC(main,eventCallback);

// gesture
[_unit, "HandSignalRadio"] call EFUNC(main,doGesture);

// get units
if (_units isEqualTo []) then {
    _units = units _unit;
};

// set waiting time for movement order
private _waitForMove = 5;

// get vehicles
private _assignedVehicles = assignedVehicles _group;

// check waypoints -- if none add new?

// commander vehicles? ~ future versions with setting ~ nkenny
if (_assignedVehicles isEqualTo []) then {
    private _vehicles = nearestObjects [_unit, ["Landvehicle"], 75];
    private _side = getNumber (configOf _unit >> "side");
    _vehicles = _vehicles select {alive _x && canMove _x && simulationEnabled _x && {(crew _x) isEqualTo []} && { !isObjectHidden _x } && { locked _x != 2 } && {(getNumber (configOf _x >> "side")) isEqualTo _side}};
    if (_vehicles isNotEqualTo []) then {
        {
            _group addVehicle _x;
            _waitForMove = _waitForMove + 2;
        } forEach _vehicles;
    };
};


// check for unregistered static weapons
private _guns = _units select {(vehicle _x) isKindOf "StaticWeapon"};
if ((_group getVariable [QEGVAR(main,staticWeaponList), []]) isEqualTo []) then {
    _group setVariable [QEGVAR(main,staticWeaponList), _guns, true];
    _waitForMove = _waitForMove + 1;
};

// check bodies
private _weaponHolders = allDeadMen findIf { (_x distance2D _unit) < 35 };
if (_weaponHolders isNotEqualTo -1) then {
    {
        [{_this call EFUNC(main,doCheckBody);}, [_x, _x getPos [20, random 360], 35], random 2] call CBA_fnc_waitAndExecute;
        _waitForMove = _waitForMove + 2;
    } forEach _units;
};

// has artillery? ~ if so fire in support?
// is aircraft or tank? Different movement waypoint?

// clear HOLD, GUARD and DISMISS waypoints
private _waypoints = waypoints _group;
if (_waypoints isNotEqualTo []) then {
    private _currentWP = _waypoints select ((currentWaypoint _group) min ((count _waypoints) - 1));
    if ((waypointType _currentWP) in ["HOLD", "GUARD", "DISMISS"]) then {
        [_group] call CBA_fnc_clearWaypoints;
    };
};

// formation changes ~ allowed here as Reinforcing units have full autonomy - nkenny
private _distance = _unit distance2D _target;
if (_distance > 500) then {
    _group setFormation selectRandom ["COLUMN", "STAG COLUMN"];
    if !(isNull objectParent _unit) then {(vehicle _unit) setUnloadInCombat [false, false];};
} else {
    if (_distance > 200) then {
        _group setFormation selectRandom ["WEDGE", "VEE", "LINE"];
    };
    if (_distance < GVAR(cqbRange)) then {
        // _group setFormation "FILE"; ~formation is set in tacticsAssault ~KRM
        [_group, _target] call FUNC(tacticsAssault);
    };
};

// pack & deploy static weapons
if !(GVAR(disableAIDeployStaticWeapons)) then {
    private _intersect = terrainIntersectASL [eyePos _unit, AGLToASL (_target vectorAdd [0, 0, 10])];
    if (_distance > 400 || {_intersect}) then {
        _units = [leader _group] call EFUNC(main,doGroupStaticPack);
    };
    if (!_intersect) then {
        _units = [leader _group, _target] call EFUNC(main,doGroupStaticDeploy);
    };
};

// shoot flare
if (!(GVAR(disableAutonomousFlares)) && {_unit call EFUNC(main,isNight)}) then {
    [_units] call EFUNC(main,doUGL);
};

// order move
[
    {
        params ["_group", "_target"];
        _group move _target;
    },
    [_group, _target],
    _waitForMove
] call CBA_fnc_waitAndExecute;

// debug
if (EGVAR(main,debug_functions)) then {
    [
        "%1 TACTICS REINFORCING (%2 with %3 units @ %4m)",
        side _unit,
        name _unit,
        count units _group,
        round (_unit distance2D _target)
    ] call EFUNC(main,debugLog);
    private _m = [_unit, format ["Reinforcing @ %1m", round (_unit distance2D _target)], _unit call EFUNC(main,debugMarkerColor), "hd_warning"] call EFUNC(main,dotMarker);
    _m setMarkerSizeLocal [0.6, 0.6];
    [{deleteMarker _this;}, _m, _delay] call CBA_fnc_waitAndExecute;
};

// end
true
