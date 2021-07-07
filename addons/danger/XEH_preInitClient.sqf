#include "script_component.hpp"

/*
Here four buttons are added:
    Toggle AI for the player group
    Easy suppress
    Easy hide
    Easy assault

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
            (group player) setVariable [QEGVAR(main,groupMemory), []];
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
    private _units = allUnits select {
        player distance _x < 22
        && {side player isEqualTo side _x}
        && {!isPlayer _x}
        && {unitReady _x}
    };
    {
        private _target = _x findNearestEnemy _x;
        if (isNull _target) then { _target = cursorObject };  // added to get a target more commonly. - nkenny
        private _firePos = [0, 0, 0];
        if (isNull _target) then {
            private _intersections = lineIntersectsSurfaces [positionCameraToWorld [0, 0, 0], positionCameraToWorld [0, 0, 10000], player, objNull, true, 1];
            if (_intersections isNotEqualTo []) then {
                _firePos = (_intersections select 0) select 0;
                _target = _x findNearestEnemy _firePos;
                if !(isNull _target) then {
                    _firePos = getPosASL _target;
                };
            };
        } else {
            _firePos = getPosASL _target;
        };
        if (_firePos isNotEqualTo [0, 0, 0]) then {
                [
                    {
                        _this remoteExec [QEFUNC(main,doSuppress), _this select 0];
                    }, [_x, _firePos, true], random 1.5
                ] call CBA_fnc_waitAndExecute;
        };
    } foreach _units;
    private _txt = format ["%1 quick suppression (%2 units)", side player, count _units];
    [["LAMBS Danger.fsm"], [_txt, 1.4]] call CBA_fnc_notify;
    true
};

// functions ~ easy hide
private _fnc_hide_AI = {
    private _pos = player getPos [25, getDir player];
    private _buildings = [_pos, 50, true, true] call EFUNC(main,findBuildings);
    private _units = (units player) select {player distance2D _x < 55 && {!isPlayer _x}};
    {
        [_x, _pos, 12, _buildings] call EFUNC(main,doHide);
    } foreach _units;
    private _txt = format ["%1 quick hide (%2 units | %3 spots)", side player, count _units, count _buildings];
    [["LAMBS Danger.fsm"], [_txt, 1.4]] call CBA_fnc_notify;
    true
};


// functions ~ easy assault
private _fnc_assault_AI = {
    private _units = (units player) select {player distance2D _x < 55 && {!isPlayer _x} && {isNull objectParent _x}};
    private _cursorObject = cursorObject;
    private _cursorPos = [0, 0, 0];
    if (isNull _cursorObject) then {
        private _intersections = lineIntersectsSurfaces [positionCameraToWorld [0, 0, 0], positionCameraToWorld [0, 0, 10000], player, objNull, true, 1];
        if (_intersections isNotEqualTo []) then {
            _cursorPos = (_intersections select 0) select 0;
        } else {
            _cursorPos = player getPos [100, getDir player]
        };
    } else {
        _cursorPos = getPos cursorObject;
    };
    private _buildings = [_cursorPos, 50, true, false] call EFUNC(main,findBuildings);
    (group player) setVariable [QEGVAR(main,groupMemory), _buildings];
    {
        private _enemy = _x findNearestEnemy _cursorPos;
        if (isNull _enemy) then {
            [_x] call EFUNC(main,doAssaultMemory);
        } else {
            [_x, _enemy] call EFUNC(main,doAssault);
        };
    } foreach _units;
    private _txt = format ["%1 quick assault (%2 units | %3 spots)", side player, count _units, count ((group player) getVariable [QEGVAR(main,groupMemory), []])];
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
    QGVAR(quickAssault),
    ["Toggle Assault","Friendly units within 50 meters of the player assaults target buildings"],
    _fnc_assault_AI,
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
