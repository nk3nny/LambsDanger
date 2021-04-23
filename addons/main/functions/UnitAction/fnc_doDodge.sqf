#include "script_component.hpp"
/*
 * Author: nkenny
 * Plays an immediate reaction unit getting hit (Internal to FSM)
 *
 * Arguments:
 * 0: unit hit <OBJECT>
 * 1: position of dange <ARRAY>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob] call lambs_main_fnc_doDodge;
 *
 * Public: No
*/
#define NEAR_DISTANCE 22

params ["_unit", ["_pos", [0, 0, 0]]];

// ACE3 captive exit
if (
    GVAR(disableAIDodge)
    || {!(_unit checkAIFeature "MOVE")}
    || {!(_unit checkAIFeature "PATH")}
) exitWith {false};

// dodge
_unit setVariable [QGVAR(currentTask), "Dodge!", GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];

// settings
private _stance = stance _unit;
private _dir = _unit getRelDir _pos;
private _still = (speed _unit) isEqualTo 0;

// prone override
if (_still && {_stance isEqualTo "PRONE"} && {!(lineIntersects [eyePos _unit, (eyePos _unit) vectorAdd [0, 0, 7]])}) exitWith {
    [_unit, ["EvasiveLeft", "EvasiveRight"] select (_dir > 180), true] call FUNC(doGesture);
    true
};

// callout
if (RND(0.8)) then {
    [_unit, "Combat", "UnderFireE", 125] call FUNC(doCallout);
};

// settings
private _nearDistance = (_unit distance2D _pos) < NEAR_DISTANCE;
private _suppression = _nearDistance && {getSuppression _unit > 0.1};

// drop stance
if (_stance isEqualTo "STAND") then {_unit setUnitPosWeak "MIDDLE";};
if (_stance isEqualTo "CROUCH" && { _suppression }) then {_unit setUnitPosWeak "DOWN";};

// experimental exit condition to prevent dodging through walls!
if (_suppression && {lineIntersects [eyePos _unit, (eyePos _unit) vectorAdd [0, 0, 7]]}) exitWith {

    // debug information to be removed before release ~ nkenny
    private _sphere = createSimpleObject ["Sign_Arrow_Large_Cyan_F", getPosWorld _unit, true];
    _sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];

    true
};

// chose anim
private _anim = call {

    // move back ~ more checks because sometimes we want the AI to move forward in CQB - nkenny
    if (_still  && { !_nearDistance } && {_dir > 320 || { _dir < 40 }}) exitWith {

        // experimental value (failed) ~ nkenny
        //_unit forceSpeed 0;

        // debug information to be removed before release ~ nkenny
        private _sphere = createSimpleObject ["Sign_Arrow_Large_Yellow_F", getPosWorld _unit, true];
        systemchat format ["doDodge.sqf %1 is still", name _unit];

        [["FastB", "FastLB", "FastRB"], ["TactB", "TactLB","TactRB"]] select _suppression;
    };

    // move left
    if ( _dir < 80) exitWith {
        [["FastL", "FastLF"], ["TactL", "TactLF"]] select _suppression;
    };

    // move right
    if (_dir > 250) exitWith {
        [["FastR", "FastRF"], ["TactR", "TactRF"]] select _suppression;
    };

    // default
    ["FastF", "TactF"] select _suppression;
};

// debug information to be removed before release ~ nkenny
private _sphere = createSimpleObject ["Sign_Arrow_Direction_F", getPosWorld _unit, true];
_sphere setObjectTexture [0, [_unit] call FUNC(debugObjectColor)];
_sphere setDir (_unit getDir _pos);

// rate of fire ~ theory the AI's shooting fsm interrupts the dodge attempt. Delay shooting to prevent running in place. (failed) ~nkenny
//_unit setWeaponReloadingTime [_unit, currentMuzzle _unit, 1.5];

// movement check ~ theory adds some pathfinding strenth inside buildings  (partial success) ~ nkenny
_unit setDestination [getPosWorld _unit, "LEADER PLANNED", false];

// execute dodge
[_unit, _anim, !_still] call FUNC(doGesture);
//[{_this call FUNC(doGesture);}, [_unit, _anim, !_still]] call CBA_fnc_execNextFrame;

// end
true
