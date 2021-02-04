#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit shares information with nearby allies modified by current radio settings
 *
 * Arguments:
 * 0: unit sharing information <OBJECT>
 * 1: enemy target <OBJECT>
 * 2: range to share information, default 350 <NUMBER>
 * 3: override radio ranges, default false <BOOLEAN>
 *
 * Return Value:
 * success
 *
 * Example:
 * [bob, angryJoe, 350, false] call lambs_danger_fnc_shareInformation;
 *
 * Public: No
*/
params ["_unit", ["_target", objNull], ["_range", 350], ["_override", false]];

// nil or captured
if (
    GVAR(radioDisabled)
    || {!(_unit call EFUNC(main,isAlive))}
    || {_unit getVariable ["ace_captives_isHandcuffed", false]}
    || {_unit getVariable ["ace_captives_issurrendering", false]}
) exitWith {false};

// no target
if (isNull _target) then {
    _target = _unit findNearestEnemy _unit;
};

_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
//_unit setVariable [QGVAR(currentTask), "Share Information", EGVAR(main,debug_functions)]; // do not update task -- sharing information is secondary info ~ nkenny

// range
([_unit, _range, _override] call FUNC(shareInformationRange)) params ["_unit", "_range"];

// find units
private _groups = allGroups select {
    (leader _x) distance2D _unit < _range
    && {[side _x, side _unit] call BIS_fnc_sideIsFriendly}
    && {behaviour leader _x != "CARELESS"}
    && {_x != group _unit}
};

{
    // share information
    if !(isNull _target) then {
        private _knowsAbout = _unit knowsAbout _target;
        [_x, [_target, _knowsAbout min GVAR(maxRevealValue)]] remoteExec ["reveal", leader _x];

        // reinforce
        if ((_x getVariable [QGVAR(enableGroupReinforce), false]) && { (_x getVariable [QGVAR(enableGroupReinforceTime), -1]) < time}) then {
            [leader _x, [getPosASL _unit, (_unit targetKnowledge _target) select 6] select (_knowsAbout > 0.5)] remoteExec [QFUNC(tacticsReinforce), leader _x];
        };
    };

    // set behaviour
    if ((leader _x) distance2D _unit < ((GVAR(combatShareRange)) min _range) && {!((leader _x) getVariable [QGVAR(disableAI), false])}) then {
        [_x, "COMBAT"] remoteExec ["setBehaviour", leader _x];
        [_x, (leader _x) getDir _unit] remoteExec ["setFormDir", leader _x];
    };
} forEach _groups;

[QGVAR(OnInformationShared), [_unit, group _unit, _target, _groups]] call EFUNC(main,eventCallback);

// play animation
if (
    RND(0.2)
    && {_range > 100}
    && {_unit distance2D _target > 4}
    ) then {
        [_unit, "HandSignalRadio"] call EFUNC(main,doGesture);
};

// debug
if (EGVAR(main,debug_functions)) then {
    // debug message
    ["%1 share information (%2 knows %3 to %4 groups @ %5m range)", side _unit, name _unit, (_unit knowsAbout _target) min 1, count _groups, round _range] call EFUNC(main,debugLog);

    // debug marker
    private _zm = [_unit, [_range,_range], _unit call EFUNC(main,debugMarkerColor), "Border"] call EFUNC(main,zoneMarker);
    private _markers = [_zm];
    {
        private _m = [_unit getHideFrom _x, "", _x call EFUNC(main,debugMarkerColor), "hd_dot"] call EFUNC(main,dotMarker);
        _m setMarkerSizeLocal [0.5, 0.5];
        _markers pushBack _m;
    } foreach ((units _target) select {_unit knowsAbout _x > 0});
    [{{deleteMarker _x;true} count _this;}, _markers, 60] call CBA_fnc_waitAndExecute;
};

// end
true
