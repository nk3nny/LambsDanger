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
 * [bob, angryJoe, 20] call lambs_danger_fnc_assault;
 *
 * Public: No
*/
params ["_unit", ["_target", objNull], ["_range", 20]];

// check if stopped or busy
if (
    stopped _unit
    || {!(_unit checkAIFeature "PATH")}
    || {!(_unit checkAIFeature "MOVE")}
    || {!(attackEnabled _unit)}
    || {currentCommand _unit in ["GET IN", "ACTION", "HEAL"]}
) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Assault", EGVAR(main,debug_functions)];

// settings
_unit setUnitPosWeak selectRandom ["UP", "UP", "MIDDLE"];
_unit forceSpeed ([_unit, _target] call FUNC(assaultSpeed));
private _rangeBuilding = linearConversion [ 0, 200, (_unit distance2d _target), 2.5, 22, true];

// Near buildings + sort near positions + add target actual location
private _buildings = [_target, _range, true, true] call EFUNC(main,findBuildings);
_buildings = _buildings select { _x distance _target < _rangeBuilding };

// exit without buildings? -- Assault or delay!
if (RND(0.8) || { _buildings isEqualTo [] }) exitWith {

    // Outdoors or indoors with 20% chance to move out
    if (RND(0.8) || { !(_unit call EFUNC(main,isIndoor)) }) then {

        // execute move
        _unit doMove (_unit getHideFrom _target);

        // debug
        if (EGVAR(main,debug_functions)) then {
            format ["%1 assaulting position (%2 @ %3m)", side _unit, name _unit, round (_unit distance (_unit getHideFrom _target))] call EFUNC(main,debugLog);
            private _sphere = createSimpleObject ["Sign_Sphere25cm_F", ATLtoASL (_unit getHideFrom _target), true];
            _sphere setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
            [{deleteVehicle _this}, _sphere, 10] call CBA_fnc_waitAndExecute;
        };
    };
};

// add actual pos
_buildings pushBack (getPosATL _target);

// execute move
_unit doMove ((selectRandom _buildings) vectorAdd [0.5 - random 1, 0.5 - random 1, 0]);

// debug
if (EGVAR(main,debug_functions)) then {
    format ["%1 assaulting buildings (%2 @ %3m)", side _unit, name _unit, round (_unit distance _target)] call EFUNC(main,debugLog);

    private _sphereList = [];
    {
        private _sphere = createSimpleObject ["Sign_Sphere10cm_F", AGLtoASL _x, true];
        _sphere setObjectTexture [0, [_unit] call EFUNC(main,debugObjectColor)];
        _sphereList pushBack _sphere;
    } foreach _buildings;
    [{{deleteVehicle _x;true} count _this}, _sphereList, 15] call CBA_fnc_waitAndExecute;
};

// end
true
