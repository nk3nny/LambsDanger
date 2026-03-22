#include "script_component.hpp"
/*
 * Author: nkenny
 * evaluates danger causes and returns most dangerous state and appropriate response
 *
 * Arguments:
 * 0: unit doing the evaluation <OBJECT>
 * 1: danger queue <ARRAY>
 *
 * Return Value:
 * array
 *
 * Example:
 * [bob, []] call lambs_danger_fnc_brain;
 *
 * Public: No
*/

/*
    DESIGN
        Immediate actions
        1 Fire
        2 Hit
        4 Explosion
        9 BulletClose

        Hide actions
        5 DeadBodyGroup
        6 DeadBody
        7 Scream
        - Panic

        Engage actions
        0 Enemy detected
        3 Enemy near
        8 CanFire

        Assess actions
        10 Assess
*/

params ["_unit", ["_queue", []]];

// empty queue ~ exit with assess!
if (_queue isEqualTo []) exitWith {
    private _causeArray = [DANGER_ASSESS, getPosWorld _unit, time + GVAR(dangerUntil), assignedTarget _unit];
    _unit setVariable [QEGVAR(main,FSMDangerCauseData), _causeArray, EGVAR(main,debug_functions)];    // debug variable
    [_causeArray, false, false, false]
};

// modify priorities ~ Unused. Disabled for performance reasons. - nkenny
// private _priorities = [_unit] call FUNC(brainAdjust);

// sort the most dangerous state
_queue = _queue apply {[GVAR(fsmPriorities) select (_x select 0), _x]};
_queue sort false;

// select cause
private _causeArray = (_queue select 0) select 1;
_causeArray params ["_dangerCause", "", "", "_dangerCausedBy"]; // "_dangerPos" and "_dangerUntil" are unused - nkenny

// debug variable
_unit setVariable [QEGVAR(main,FSMDangerCauseData), _causeArray, EGVAR(main,debug_functions)];

// assess actions
if (_dangerCause isEqualTo DANGER_ASSESS) exitWith {
    [_causeArray, false, false, false]
};

// immediate actions
private _group = group _unit;
if (_dangerCause in [DANGER_HIT, DANGER_BULLETCLOSE, DANGER_EXPLOSION, DANGER_FIRE]) exitWith {
    [_causeArray, (side _group) isNotEqualTo side (group _dangerCausedBy) && (getSuppression _unit < 0.9), false, false]
};

// engage actions
if (_dangerCause in [DANGER_ENEMYDETECTED, DANGER_ENEMYNEAR, DANGER_CANFIRE]) exitWith {

    // share information
    if (_dangerCause isEqualTo DANGER_ENEMYNEAR) then {
        //[_unit, ["gestureFreeze", "gesturePoint"] select (_unit distance2D _dangerPos < 100)] call EFUNC(main,doGesture);
        [_unit, ["Combat", "Stealth"] select (behaviour _unit isEqualTo "STEALTH"), "contact", 100] call EFUNC(main,doCallout);
        [_unit, _dangerCausedBy, EGVAR(main,radioShout), true] call EFUNC(main,doShareInformation);
    };

    // return
    [_causeArray, false, false, (side _group) isNotEqualTo side (group _dangerCausedBy)]
};

// hide actions
private _panic = RND(1 - GVAR(panicChance)) && {getSuppression _unit > 0.9};
if (_panic || {_dangerCause in [DANGER_DEADBODYGROUP, DANGER_DEADBODY, DANGER_SCREAM]}) exitWith {

    // panic function
    if (_panic) then {
        [_unit] call EFUNC(main,doPanic);
    };

    // return
    [_causeArray, false, true, false]
};

// end
[_causeArray, false, false, false]
