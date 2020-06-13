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
            {
                _x setVariable [QGVAR(disableAI), false];    // added to ensure it triggers -- nkenny
            } foreach units player;
        } else {
            GVAR(disableAIPlayerGroup) = true;
            {
                _x setUnitPosWeak "AUTO";
                _x setVariable [QGVAR(disableAI), true];
            } foreach units player;
        };
    private _txt = format ["%1 toggled AI %2", side player, ["on", "off"] select (GVAR(disableAIPlayerGroup))];
    [["LAMBS Danger.fsm"], [_txt, 1.4], true] call CBA_fnc_notify;
    true
};

// functions ~ easy suppress
private _fnc_suppress_AI = {
    private _units = allUnits select {side _x isEqualTo side player && {_x distance player < 22} && {!isPlayer _x} && {unitReady _x}};
    {
        private _target = _x findNearestEnemy _x;
        if (isNull _target) then { _target = cursorObject };  // added to get a target more commonly. - nkenny
        private _firePos = [0, 0, 0];
        if (isNull _target) then {
            private _intersections = lineIntersectsSurfaces [positionCameraToWorld [0, 0, 0], positionCameraToWorld [0, 0, 10000], player, objNull, true, 1];
            if !(_intersections isEqualTo []) then {
                _firePos = (_intersections select 0) select 0;
                _target = _x findNearestEnemy _firePos;
                if !(isNull _target) then {
                    _firePos = getPosASL _target;
                };
            };
        } else {
            _firePos = getPosASL _target;
        };
        if !(_firePos isEqualTo [0, 0, 0]) then {
            _x doSuppressiveFire _firePos;
            _x suppressFor 6 + (random 5);
        };
    } foreach _units;
    private _txt = format ["%1 quick suppression (%2 units)",side player,count _units];
    [["LAMBS Danger.fsm"], [_txt, 1.4]] call CBA_fnc_notify;
    true
};

// functions ~ easy hide
private _fnc_hide_AI = {
    private _buildings = [player getPos [15, getdir player], 38, true, true] call EFUNC(main,findBuildings);
    private _units = (units player) select {_x distance player < 55 && {!isPlayer _x}};
    {
        [_x, _x getPos [25, random 360], 10, _buildings] call FUNC(doHide);
    } foreach _units;
    private _txt = format ["%1 quick hide (%2 units)",side player,count _units];
    [["LAMBS Danger.fsm"], [_txt, 1.4]] call CBA_fnc_notify;
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
    ["Toggle Suppressive fire","Friendly units within 20 meters of the player suppress target location"],
    _fnc_suppress_AI,
    ""
] call CBA_fnc_addKeybind;

// buttons
[
    COMPONENT_NAME,
    QGVAR(quickHide),
    ["Toggle Hiding","Friendly units within 50 meters of the player quickly seek cover"],
    _fnc_hide_AI,
    ""
] call CBA_fnc_addKeybind;
