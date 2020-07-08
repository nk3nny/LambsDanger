#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader calls for extended aggresive manoeuvres towards buildings or location
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Group threat unit <OBJECT> or position <ARRAY>
 * 2: Units in group, default all <ARRAY>
 * 3: How many assault cycles, default four <NUMBER>
 * 4: Overwatch destination <ARRAY>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_leaderManoeuvre;
 *
 * Public: No
*/
params ["_unit", "_target", ["_units", []], ["_cycle", 3], ["_overwatch", []]];

// stopped or static
if (!(attackEnabled _unit) || {stopped _unit}) exitWith {false};

// find target
_target = _target call CBA_fnc_getPos;

// check CQB ~ exit if in close combat other functions will do the work - nkenny
if (_unit distance2D _target < GVAR(CQB_range)) exitWith {

    [_unit, _target] call FUNC(leaderGarrison);

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
    if (!(isNull objectParent _x) && { isTouchingGround vehicle _x } && { canFire vehicle _x }) then {
        _vehicles pushBackUnique vehicle _x;
    };
} foreach (units _unit select { _unit distance2D _x < 350 && { canFire _x }});

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
_unit setVariable [QGVAR(currentTask), "Leader Flank", EGVAR(main,debug_functions)];

// gesture
[_unit, ["gestureGo"]] call EFUNC(main,doGesture);
[_units select (count _units - 1), ["gestureGoB"]] call EFUNC(main,doGesture);

// leader callout
[_unit, "combat", selectRandom ["OnYourFeet", "Advance", "FlankLeft ", "FlankRight"], 125] call EFUNC(main,doCallout);

// ready group
(group _unit) setFormDir (_unit getDir _target);
_unit doMove _overwatch;        // ~ to ensure some movement! -nkenny
//(group _unit) move _overwatch;  ~ removed move command alters current WP. -nkenny

// leader smoke ~ deploy concealment to enable movement
if (RND(0.5)) then {[_unit, _overwatch] call EFUNC(main,doSmoke);};

// manoeuvre function
private _fnc_manoeuvre = {
    params ["_cycle", "_units", "_vehicles", "_pos", "_overwatch", "_fnc_manoeuvre"];

    // update
    _units = _units select { _x call EFUNC(main,isAlive) && { _x distance2D (_pos select 0) > 10 } && { !isPlayer _x } };
    _vehicles = _vehicles select { canFire _x };
    _cycle = _cycle - 1;

    {
        private _posASL = AGLtoASL (selectRandom _pos);

        // suppress
        if (!(terrainIntersectASL [eyePos _x, _posASL]) && {RND(0.65)}) then {

            _x doWatch ASLtoAGL _posASL;
            [_x, _posASL, true] call FUNC(suppress);

        } else {

            // manoeuvre
            _x forceSpeed 4;
            _x setUnitPosWeak "MIDDLE";
            _x setVariable [QGVAR(currentTask), "Group Flank", EGVAR(main,debug_functions)];
            _x setVariable [QGVAR(forceMove), getSuppression _x > 0.5];

            // force movement
            _x doMove _overwatch;

        };
    } foreach _units;

    // vehicles
    {
        private _posAGL = selectRandom _pos;
        _x doWatch _posAGL;
        [_x, _posAGL] call FUNC(vehicleSuppress);

    } foreach _vehicles;

    // recursive cyclic
    if (_cycle > 0 && {!(_units isEqualTo [])}) then {
        [
            _fnc_manoeuvre,
            [_cycle, _units, _vehicles, _pos, _overwatch, _fnc_manoeuvre],
            12 + random 9
        ] call CBA_fnc_waitAndExecute;
    };
};

// execute recursive cycle
[_cycle, _units, _vehicles, _pos, _overwatch, _fnc_manoeuvre] call _fnc_manoeuvre;

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 group FLANK (%2 with %3 units and %6 vehicles @ %4m with %5 positions)", side _unit, name _unit, count _units, round (_unit distance2D _overwatch), count _pos, count _vehicles] call EFUNC(main,debugLog);

    _overwatch set [2, 0];
    private _arrow = createSimpleObject ["Sign_Arrow_F", AGLToASL _overwatch, true];
    _arrow setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
    [{deleteVehicle _this}, _arrow, 30] call CBA_fnc_waitAndExecute;
};

// end
true
