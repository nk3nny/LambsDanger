#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit shares information with nearby allies modified by current radio settings
 *
 * Arguments:
 * 0: Unit sharing information <OBJECT>
 * 1: Enemy target <OBJECT>
 * 2: Range to share information, default 350 <NUMBER>
 * 3: Override radio ranges, default false <BOOLEAN>
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

// no target
if (isNull _target) then {
    _target = _unit findNearestEnemy _unit;
};

// nil or captured
if (
    isNull _target
    //|| {_unit distance _target > viewDistance}
    || {_unit getVariable ["ace_captives_isHandcuffed", false]}
    || {_unit getVariable ["ace_captives_issurrendering", false]}
    || {GVAR(radio_disabled)}
) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
//_unit setVariable [QGVAR(currentTask), "Share Information", EGVAR(main,debug_functions)]; // do not update task -- sharing information is secondary info ~ nkenny

// range
([_unit, _range, _override] call FUNC(shareInformationRange)) params ["_unit", "_range"];

// find units
private _groups = allGroups select {
    leader _x distance2D _unit < _range
    && {[side _x, side _unit] call BIS_fnc_sideIsFriendly}
    && {behaviour leader _x != "CARELESS"}
    && {_x != group _unit}
};

private _knowsAbout = _unit knowsAbout _target;

// share information
{
    if !(isNull _target) then {
        [_x, [_target, _knowsAbout min GVAR(maxRevealValue)]] remoteExec ["reveal", leader _x];
    };

    if ((leader _x) distance2D _unit < ((GVAR(combatShareRange)) min _range) && {!((leader _x) getVariable [QGVAR(disableAI), false])}) then {
        [_x, "COMBAT"] remoteExec ["setBehaviour", leader _x];
        [_x, (leader _x) getDir _unit] remoteExec ["setFormDir", leader _x];
        if (local leader _x && {_x getVariable [QGVAR(contact), 0] < time}) then {[leader _x] call FUNC(tactics);};
    };
} forEach _groups;

[QGVAR(OnInformationShared), [_unit, group _unit, _target, _groups]] call EFUNC(main,eventCallback);

// play animation
if (RND(0.2) && {_range > 100} && {_unit distance2D _target > 4}) then {[_unit, "HandSignalRadio"] call EFUNC(main,doGesture);};

// debug
if (EGVAR(main,debug_functions)) then {

    // debug message
    ["%1 share information (%2 knows %3 to %4 groups @ %5m range)", side _unit, name _unit, (_unit knowsAbout _target) min 1, count _groups, round _range] call EFUNC(main,debugLog);

    // debug marker
    private _m = [_unit, "", _unit call EFUNC(main,debugMarkerColor),"mil_dot"] call EFUNC(main,dotMarker);
    private _mt = [_target, "target", _target call EFUNC(main,debugMarkerColor),"mil_dot"] call EFUNC(main,dotMarker);
    private _zm = [_unit, [_range,_range], _unit call EFUNC(main,debugMarkerColor), "Border"] call EFUNC(main,zoneMarker);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt, _zm], 60] call CBA_fnc_waitAndExecute;
};

// end
true
