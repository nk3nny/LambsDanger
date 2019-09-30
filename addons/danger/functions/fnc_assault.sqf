#include "script_component.hpp"
// Assault Position/Building
// version 1.41
// by nkenny

// init
params ["_unit",["_target",objNull],["_range",30]];

// check if stopped 
//if (!(_unit checkAIFeature "PATH") || {!(_unit checkAIFeature "MOVE")}) exitWith {};
if (stopped _unit || {!(attackEnabled _unit)}) exitWith {false};

// settings
_unit setUnitPosWeak "UP";

// Near buildings + sort near positions + add target actual location
_buildings = [_target,_range,true,true] call FUNC(nearBuildings);
_buildings pushBack (getPosATL _target);
_buildings = _buildings select {_x distance2d _target < 5};

// exit without buildings? -- Assault or delay!
if (count _buildings < 2 || {random 1 > 0.8}) exitWith {

    // Outdoors or indoors with 5% chance to move out
    if (!(_unit call FUNC(indoor)) || {random 1 > 0.95}) then {

    // execute move
    _unit doMove (_unit getHideFrom _target);
    //_unit moveTo (_unit getHideFrom _target); //-- testing moveTo for lower level order

    // debug
    if (GVAR(debug_functions)) then {systemchat format ["%1 assaulting position (%2m)",side _unit,round (_unit distance2d _target)];};
    };
};

// execute move 
_unit doMove ((selectRandom _buildings) vectorAdd [0.7 - random 1.4,0.7 - random 1.4,0]);

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 checking buildings (%2m)",side _unit,round (_unit distance2d _target)];};
 
// end
true