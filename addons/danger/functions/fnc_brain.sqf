#include "script_component.hpp"
/*
 * Author: nkenny
 * evaluates danger causes and returns most dangerous state and appropriate response
 *
 * Arguments:
 * 0: unit doing the avaluation <OBJECT>
 * 1: danger queue <ARRAY>
  *
 * Return Value:
 * array
 *
 * Example:
 * [bob, []] call lambs_danger_fnc_dangerBrain;
 *
 * Public: No
*/

/*
    DESIGN
        Immediate actions
        2 Hit
        9 BulletClose

        Hide actions
        0 Enemy detected (but far)
        4 Explosion
        7 Scream

        Engage actions
        0 Enemy detected (but near)
        1 Fire
        3 Enemy near
        8 CanFire

        Assess actions
        5 DeadBodyGroup
        6 DeadBody
*/


params ["_unit", ["_queue", []]];

// init ~ immediate action, hide, engage, assess
private _return = [false, false, false, false];

// empty queue ~ exit with assess!
if (_queue isEqualTo []) exitWith {

    [false, false, false, true, [-1, getpos _unit, time + GVAR(dangerUntil), _unit findNearestEnemy _unit, 0]]

};

// modify priorities ~ own function!
private _priorities = [_unit] call FUNC(brainAdjust);

// pick the most relevant danger cause
private _priority = -1;
private _index = -1;
{
    private _cause = _x select 0;
    if ((_priorities select _cause) > _priority) then {
        _index = _forEachIndex;
    };
} foreach _queue;

// select cause
private _causeArray = _queue select _index;
_causeArray params ["_cause", "_dangerPos", "_dangerUntil", "_dangerCausedBy"];
_causeArray pushBack (_unit distance2D _dangerPos); // add distance to dangerPos

// Immediate actions
if (_cause in [2, 9]) then {
    _return set [0, true];
};

// hide actions
if (_cause in [0, 4, 7] || {getSuppression _unit > 0.9 && {random 100 < GVAR(panic_chance)}}) then {
    _return set [1, true];

    // enemy near? don't hide
    if (_cause isEqualTo 0 && {(_unit distance2D _dangerCausedBy) < GVAR(CQB_range)}) then {
        _return set [1, false];
    };
};

// engage actions   // should check all friendly sides?
if (_cause in [0, 1, 3, 8] && {!(side _unit isEqualTo side _dangerCausedBy)}) then {
    _return set [2, true];
    _return set [1, _unit knowsAbout _dangerCausedBy < 1.4];    // hide if target unknown!
};

// assess actions
if (_cause in [5, 6]) then {
    _return set [3, true];
};

// gesture + share information
if (_cause isEqualto 0) then {
    if (RND(0.5)) then {[_unit, "gesturePoint"] call EFUNC(main,doGesture);};
    if (isFormationLeader _unit) then {[_unit, _dangerCausedBy, GVAR(radio_shout), true] call FUNC(shareInformation);};
};

// modify return
_return pushBack _causeArray;

// end
_return
