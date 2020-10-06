#include "script_component.hpp"
/*
 * Author: nkenny
 * Group conducts probing flanking manoeuvre
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Group threat unit <OBJECT> or position <ARRAY>
 * 2: Units in group, default all <ARRAY>
 * 3: How many assault cycles, default four <NUMBER>
 * 4: Overwatch destination <ARRAY>
 * 5: Time until tactics is reset, default 30s <NUMBERS>
 *
 * Return Value:
 * Bool
 *
 * Example:
 * [bob, angryBob] call liteDanger_fnc_tacticsFlank;
 *
 * Public: No
*/
params ["_unit", "_target", ["_units", []], ["_cycle", 3], ["_overwatch", []], ["_delay", 60]];

// find target
_target = _target call CBA_fnc_getPos;

private _group = group _unit;
// reset tactics
[
    {
        params ["_group", "_speedMode"];
        if (!isNull _group) then {
            _group setVariable [QGVAR(tactics), nil];
            _group setSpeedMode _speedMode;
            _group setVariable [QGVAR(tacticsTask), nil];
        };
    },
    [_group, speedMode _unit],
    _delay
] call CBA_fnc_waitAndExecute;

// alive unit
if !(_unit call EFUNC(main,isAlive)) exitWith {false};

// check CQB ~ exit if in close combat other functions will do the work - nkenny
if (_unit distance2D _target < GVAR(CQB_range)) exitWith {
    [_unit, _target] call FUNC(tacticsGarrison);
    false
};

// find units
if (_units isEqualTo []) then {
    _units = [_unit, 200] call EFUNC(main,findReadyUnits);
};
if (_units isEqualTo []) exitWith {false};

// find vehicles
private _vehicles = [];
{
    private _vehicle = vehicle _x;
    if (_x != _vehicle && { isTouchingGround _vehicle } && { canFire _vehicle }) then {
        _vehicles pushBackUnique _vehicle;
    };
} foreach ((units _unit) select { (_unit distance2D _x) < 350 && { canFire _x }});

// sort building locations
private _pos = [_target, 12, true, false] call EFUNC(main,findBuildings);
_pos pushBack _target;

// find overwatch position
if (_overwatch isEqualTo []) then {
    private _distance2D = ((_unit distance2D _target) / 2) min 200;
    _overwatch = selectBestPlaces [_target, _distance2D, "(2 * hills) + (2 * forest + trees + houses) - (2 * meadow) - (2 * windy) - (2 * sea) - (10 * deadBody)", 100 , 3] apply {[(_x select 0) distance2D _unit, _x select 0]};
    _overwatch sort true;
    _overwatch = _overwatch apply {_x select 1};
    _overwatch = _overwatch select {!(surfaceIsWater _x)};
    _overwatch pushBack ([getPos _unit, _distance2D, 100, 8, _target] call EFUNC(main,findOverwatch));
    _overwatch = _overwatch select 0;
};

// set tasks
_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Tactics Flank", EGVAR(main,debug_functions)];

// set group task
_group setVariable [QGVAR(tacticsTask), "Flanking", EGVAR(main,debug_functions)];

// gesture
[_unit, ["gestureGo"]] call EFUNC(main,doGesture);
[_units select (count _units - 1), "gestureGoB"] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", selectRandom ["OnYourFeet", "Advance", "FlankLeft ", "FlankRight"], 125] call EFUNC(main,doCallout);

// ready group
_group setFormDir (_unit getDir _target);
_unit doMove _overwatch;

// leader smoke ~ deploy concealment to enable movement
[_unit, _overwatch] call EFUNC(main,doSmoke);

// function
[_cycle, _units, _vehicles, _pos, _overwatch] call FUNC(doGroupFlank);

// set speedmode    // NB: check this one - nkenny
//_unit setSpeedMode "FULL";

// debug
if (EGVAR(main,debug_functions)) then {
    ["%1 TACTICS FLANK (%2 with %3 units and %6 vehicles @ %4m with %5 positions)", side _unit, name _unit, count _units, round (_unit distance2D _overwatch), count _pos, count _vehicles] call EFUNC(main,debugLog);

    _overwatch set [2, 0];
    private _arrow = createSimpleObject ["Sign_Arrow_F", AGLToASL _overwatch, true];
    _arrow setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
    [{deleteVehicle _this}, _arrow, 30] call CBA_fnc_waitAndExecute;
};

// end
true
