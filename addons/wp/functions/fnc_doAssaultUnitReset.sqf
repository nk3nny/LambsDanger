#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit Assault/retreat status is reset
 *
 * Arguments:
 * 0: Unit to be reset <OBJECT>
 * 1: Unit is in retreat mode <BOOLEAN>
 *
 * Return Value:
 * unit
 *
 * Example:
 * [bob] call lambs_wp_fnc_doAssaultUnitReset;
 *
 * Public: No
*/
params ["_unit", ["_retreat", false]];

_unit setVariable [QEGVAR(danger,disableAI), nil];
_unit setVariable [QEGVAR(danger,forceMove), nil];

// stance
_unit forceSpeed -1;
_unit setUnitPos "AUTO";
_unit doMove getPosASL _unit;
_unit doFollow leader _unit;

// AI
_unit enableAI "FSM";
_unit enableAI "COVER";
_unit enableAI "SUPPRESSION";

// double check retreat
if (!_retreat && {animationState _unit in ["apanpknlmsprsnonwnondf", "apanpercmsprsnonWnondf"]}) then {_retreat = true};

// retreat
if (_retreat) then {
    _unit switchMove (["AmovPercMsprSlowWrflDf_AmovPpneMstpSrasWrflDnon", "AmovPercMsprSnonWnonDf_AmovPpneMstpSnonWnonDnon"] select (primaryWeapon _unit isEqualTo ""));
    _unit enableAI "TARGET";
    _unit enableAI "AUTOTARGET";
    _unit doWatch ObjNull;
};

_unit