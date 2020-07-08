#include "script_component.hpp"
/*
 * Author: nkenny
 * Leader Declares Contact!
 *
 * Arguments:
 * 0: Group leader <OBJECT>
 * 1: Dangerous target <OBJECT>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe] call lambs_danger_fnc_leaderContact;
 *
 * Public: No
*/
params ["_unit", "_target"];

// share information
[_unit, _target] call FUNC(shareInformation);

// movement
_unit forceSpeed 0;
_unit setUnitPosWeak "MIDDLE";

// gesture
[_unit, ["gesturePoint"]] call EFUNC(main,doGesture);

// gather the stray flock
{
    _x doFollow _unit;
    _x setVariable [QGVAR(forceMOVE), true];
} forEach (( units _unit ) select { _x call EFUNC(main,isAlive) && {_x distance _unit > 95} });

// deploy flares
if (!(GVAR(disableAutonomousFlares)) && {_unit call EFUNC(main,isNight)}) then {
    [
        {
            params ["_unit"];
            private _units = units _unit select { _x call EFUNC(main,isAlive) && {!(lineIntersects [eyepos _x, (eyepos _x) vectorAdd [0, 0, 10]])}};
            [_units] call EFUNC(main,doUGL);
        }, [_unit], 1.5
    ] call CBA_fnc_waitAndExecute;
};

// change formation
(group _unit) setFormation (group _unit getVariable [QGVAR(dangerFormation), formation _unit]);

// call event system
[QGVAR(onContact), [_unit, group _unit, _target]] call EFUNC(main,eventCallback);

// end
true
