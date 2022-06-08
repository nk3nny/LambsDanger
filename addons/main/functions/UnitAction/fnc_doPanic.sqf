#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit acts in panic
 *
 * Arguments:
 * 0: unit panicking <OBJECT>
 *
 * Return Value:
 * boolean
 *
 * Example:
 * [bob] call lambs_main_fnc_doPanic;
 *
 * Public: No
*/
params [["_unit", ObjNull, [ObjNull]]];

// exit if unit is dead or otherwis captured
if (
    !(_unit call FUNC(isAlive))
    || {_unit getVariable ["ace_captives_isHandcuffed", false]}
    || {_unit getVariable ["ace_captives_issurrendering", false]}
) exitWith {false};

// settings
//_unit setVariable [QGVAR(currentTarget), objNull, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Panic", GVAR(debug_functions)];

// eventhandler
[QGVAR(OnPanic), [_unit, group _unit]] call FUNC(eventCallback);

// callout
[_unit, "Stealth", "panic", 55] call FUNC(doCallout);

// debug
if (GVAR(debug_functions)) then {format ["%1 panic! (%2)", side _unit, name _unit] call FUNC(debugLog);};

// force AI
_unit doWatch objNull;
_unit setVariable [QEGVAR(danger,forceMove), true];

// indoor -- gesture
if (RND(0.8) || {lineIntersects [eyePos _unit, (eyePos _unit) vectorAdd [0, 0, 7]]}) exitWith {

    // action
    _unit forceSpeed 0;
    _unit setUnitPos selectRandom ["MIDDLE", "MIDDLE", "DOWN"];
    private _move = call {
        private _stance = stance _unit;
        if (_stance isEqualTo "PRONE") exitWith {"AmovPpneMstpSnonWnonDnon_AmovPknlMstpSnonWnonDnon"};  // stand up crouch
        if (_stance isEqualTo "CROUCH") exitWith {"AmovPpneMstpSnonWnonDnon_AmovPercMstpSnonWnonDnon"};  // stand up stand
        "AmovPercMstpSnonWnonDnon_AmovPpneMstpSnonWnonDnon"
    };
    _unit switchMove _move;
    [{_this playMoveNow selectRandom ["AmovPercMstpSnonWnonDnon_Scared", "AmovPercMstpSnonWnonDnon_Scared2"];}, _unit] call CBA_fnc_execNextFrame;  // ~ set civilian animation - nkenny

    // return
    [_unit, 6 + random 4] call FUNC(doPanicReset);
};

// outdoor -- crawl
if (RND(0.25)) exitWith {

    // action
    _unit setUnitPos "DOWN";
    [_unit, ["FastB", "FastLB", "FastRB"], true] call EFUNC(main,doGesture);

    // chance to randomly fire weapon
    if ((RND(0.4)) && {!(primaryWeapon _unit isEqualTo "")}) then {
        _unit forceWeaponFire [primaryWeapon _unit, selectRandom (getArray (configFile >> "CfgWeapons" >> (primaryWeapon _unit) >> "modes"))];
    };

    // chance to randomly wave
    if (RND(0.4)) then {
        [_unit, "GestureCover"] call FUNC(doGesture);
    };

    // return
    [_unit, 6 + random 6] call FUNC(doPanicReset);
};

// outdoor -- hide

// animation
[_unit, "GestureAgonyCargo"] call FUNC(doGesture);

// action
[_unit, _unit getPos [-100, getDir _unit], 55] call FUNC(doHide);

// stance
_unit setUnitPos selectRandom ["MIDDLE", "UP"];

// reset
[_unit, 8 + random 6, true] call FUNC(doPanicReset);

// end
true
