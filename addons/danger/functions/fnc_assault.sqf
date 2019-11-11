#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit assaults building positions or open terrain according ot enemy position
 *
 * Arguments:
 * 0: Unit assault cover <OBJECT>
 * 1: Enemy <OBJECT>
 * 2: Range to find buildings, default 30 <NUMBER>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob, angryJoe, 30] call lambs_danger_fnc_assault;
 *
 * Public: No
*/
params ["_unit", ["_target", objNull], ["_range", 30], "_rangeBuilding"];

// check if stopped or busy
if (
    stopped _unit
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
    || {!(attackEnabled _unit)}
    || {currentCommand _unit in ["GET IN", "ACTION", "HEAL"]}
) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Assault"];

// settings
_unit setUnitPosWeak "UP";
_rangeBuilding = linearConversion [ 0, 200, (_unit distance2d _target), 1.5, 20, true];

// Near buildings + sort near positions + add target actual location
private _buildings = [_target, _range, true, true] call FUNC(findBuildings);
_buildings pushBack (getPosATL _target);
_buildings = _buildings select { _x distance _target < _rangeBuilding };

// exit without buildings? -- Assault or delay!
if (RND(0.8) || { count _buildings < 2 }) exitWith {

    // Outdoors or indoors with 20% chance to move out
    if (RND(0.8) || { !(_unit call FUNC(indoor)) }) then {
        // execute move
        _unit doMove (_unit getHideFrom _target);
        //_unit moveTo (_unit getHideFrom _target); //-- testing moveTo for lower level order

        // debug
        if (GVAR(debug_functions)) then {systemchat format ["%1 assaulting position (%2m)", side _unit, round (_unit distance _target)];};
    };
};

// execute move
_unit doMove ((selectRandom _buildings) vectorAdd [0.7 - random 1.4, 0.7 - random 1.4, 0]);

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 assaulting buildings (%2m)", side _unit, round (_unit distance _target)];};

// end
true
