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

// nil or captured
if (
    _unit distance _target > viewDistance
    || {_unit getVariable ["ace_captives_isHandcuffed", false]}
    || {_unit getVariable ["ace_captives_issurrendering", false]}
    || {GVAR(radio_disabled)}
) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target, EGVAR(main,debug_functions)];
_unit setVariable [QGVAR(currentTask), "Share Information", EGVAR(main,debug_functions)];

// range
([_unit, _range, _override] call FUNC(shareInformationRange)) params ["_unit", "_range"];

// find units
private _groups = allGroups select {
    leader _x distance2d _unit < _range
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
        _x setBehaviour "COMBAT";
        _x setFormDir ((leader _x) getDir _unit);
    };
} forEach _groups;

[QGVAR(OnInformationShared), [_unit, group _unit, _target, _groups]] call EFUNC(main,eventCallback);

// play animation
if (RND(0.2) && {_range > 100}) then {[_unit, ["HandSignalRadio"]] call EFUNC(main,doGesture);};

// debug
if (EGVAR(main,debug_functions)) then {

    // debug message
    format ["%1 share information (%2 knows %3 to %4 groups @ %5m range)", side _unit, name _unit, (_unit knowsAbout _target) min 1, count _groups, round _range] call EFUNC(main,debugLog);

    // debug marker
    private _m = [_unit, "", _unit call EFUNC(main,debugMarkerColor),"mil_dot"] call EFUNC(main,dotMarker);
    private _mt = [_target, "target", _target call EFUNC(main,debugMarkerColor),"mil_dot"] call EFUNC(main,dotMarker);
    private _zm = [_unit, [_range,_range], _unit call EFUNC(main,debugMarkerColor), "Border"] call EFUNC(main,zoneMarker);
    [{{deleteMarker _x;true} count _this;}, [_m, _mt, _zm], 60] call CBA_fnc_waitAndExecute;
};

// end
true
