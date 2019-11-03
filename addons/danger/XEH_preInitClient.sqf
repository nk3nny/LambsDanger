#include "script_component.hpp"

/*
Here three buttons are added:
    Toggle AI for the player group
    Easy suppress
    Easy hide

These functions and buttons could conceivably be moved to their own module.
They might also benefit from added interface and more nuanced functions handling.
That said: within the current scope of the AI mod. They can make a comfortable
home here. Until revisited by more capable personnell.
- nkenny
*/

// adopted from ACE3 -- not sure if necessary?
if (!hasInterface) exitWith {};

// functions ~ toggle AI
private _fnc_toggle_AI = {
    if (GVAR(disableAIPlayerGroup)) then {
            GVAR(disableAIPlayerGroup) = false;
            {_x setUnitPosWeak "AUTO"} foreach units player;
        } else {
            GVAR(disableAIPlayerGroup) = true;
        };
    systemchat format ["%1 toggled AI %2",side player, if (GVAR(disableAIPlayerGroup)) then {"on"} else {"off"}];
    true
};

// functions ~ easy suppress
private _fnc_suppress_AI = {
    private _units = allUnits select {side _x isEqualTo side player && {_x distance player < 22} && {!isPlayer _x}};
    {
        private _target = _x findNearestEnemy _x;
        _x doSuppressiveFire getposASL _target;
        _x suppressFor 6 + (random 5);
    } foreach _units;
    systemchat format ["%1 quick suppression (%2 units)",side player,count _units];
    true
};

// functions ~ easy hide
private _fnc_hide_AI = {
    private _buildings = [player, 38, true, true] call FUNC(findBuildings);
    private _units = (units player) select {_x distance player < 55 && {!isPlayer _x}};
    {
        [_x, _x getPos [25,random 360], 10, _buildings] call FUNC(hideInside);
    } foreach _units;
    systemchat format ["%1 quick hide (%2 units)",side player,count _units];
    true
};

// buttons
[
    COMPONENT_NAME,
    QGVAR(disableAIPlayerGroup),
    ["Toggle Player Group AI","Toggle danger.fsm for player group"],
    _fnc_toggle_AI,
    ""
] call CBA_fnc_addKeybind;

// buttons
[
    COMPONENT_NAME,
    QGVAR(quickSuppression),
    ["Toggle suppressive fire","Friendly units within 20 meters of the player suppress target location"],
    _fnc_suppress_AI,
    ""
] call CBA_fnc_addKeybind;

// buttons
[
    COMPONENT_NAME,
    QGVAR(quickHide),
    ["Toggle hiding","Friendly units within 50 meters of the player quickly seek cover"],
    _fnc_hide_AI,
    ""
] call CBA_fnc_addKeybind;
