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

// set new time
private _group = group _unit;
_group setVariable [QGVAR(enableGroupReinforceTime), time + _delay, true];

// set tasks
_target = _target call CBA_fnc_getPos;
_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Reinforce", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QGVAR(tacticsTask), "Reinforcing", EGVAR(main,debug_functions)];

// gesture
[_unit, "HandSignalRadio"] call EFUNC(main,doGesture);

// get units
if (_units isEqualTo []) then {
    _units = units _unit;
};

// check waypoints -- if none add new?
// commander vehicles? ~ future versions with setting ~ nkenny
// has artillery? ~ if so fire in support?
// is aircraft or tank? Differrent movement waypoint?

// formation changes ~ allowed here as Reinforcing units have full autonomy - nkenny
private _distance = _unit distance2D _target;
if (_distance > 600) then {
    _unit setFormation "COLUMN";
} else {
    if (_distance > 200) then {_unit setFormation selectRandom ["WEDGE", "VEE", "LINE"];};
    if (_distance < GVAR(cqbRange)) then {_unit setFormation "FILE";};
};

// pack & deploy static weapons
if !(GVAR(disableAIDeployStaticWeapons)) then {
    private _intersect = terrainIntersectASL [eyePos _unit, AGLtoASL (_target vectorAdd [0, 0, 10])];
    if (_distance > 400 || {_intersect}) then {
        _units = [_units] call FUNC(leaderStaticPack);
    };
    if (!_intersect) then {
        _units = [_units, _target] call FUNC(leaderStaticDeploy);
    };
};

// shoot flare
if (!(GVAR(disableAutonomousFlares)) && {_unit call EFUNC(main,isNight)}) then {
    [_units] call EFUNC(main,doUGL);
};

// order move
_units doMove _target;

// debug
if (EGVAR(main,debug_functions)) then {
    [
        "%1 TACTICS REINFORCING (%2 with %3 units @ %4m)",
        side _unit,
        name _unit,
        count _units,
        round (_unit distance2D _target)
    ] call EFUNC(main,debugLog);
    private _m = [_unit, format ["Reinforcing @ %1m", round (_unit distance2D _target)], _unit call EFUNC(main,debugMarkerColor), "hd_warning"] call EFUNC(main,dotMarker);
    _m setMarkerSizeLocal [0.6, 0.6];
    [{deleteMarker _this;}, _m, _delay] call CBA_fnc_waitAndExecute;
};

// end
true
