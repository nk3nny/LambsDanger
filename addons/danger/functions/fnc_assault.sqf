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
params ["_unit", ["_target", objNull], ["_range", 30]];

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
_unit setUnitPosWeak selectRandom ["UP", "UP", "UP", "MIDDLE"];
private _rangeBuilding = linearConversion [ 0, 200, (_unit distance2d _target), 2.5, 22, true];

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

        // debug
        if (GVAR(debug_functions)) then {
            systemchat format ["%1 assaulting position (%2m)", side _unit, round (_unit distance _target)];
            private _sphere = createSimpleObject ["Sign_Sphere25cm_F", AGLtoASL (_unit getHideFrom _target), true];
            _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
            [{deleteVehicle _this}, _sphere, 10] call cba_fnc_waitAndExecute;
        };
    };
};

// execute move
_unit doMove ((selectRandom _buildings) vectorAdd [0.5 - random 1, 0.5 - random 1, 0]);

// debug
if (GVAR(debug_functions)) then {
    systemchat format ["%1 assaulting buildings (%2m)", side _unit, round (_unit distance _target)];

    private _sphereList = [];
    {
        private _sphere = createSimpleObject ["Sign_Sphere10cm_F", AGLtoASL _x, true];
        _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
        _sphereList pushBack _sphere;
    } foreach _buildings;
    [{{deleteVehicle _x;true} count _this}, _sphereList, 15] call cba_fnc_waitAndExecute;
};

// end
true
