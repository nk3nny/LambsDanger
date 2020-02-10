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
) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target];
_unit setVariable [QGVAR(currentTask), "Share Information"];

// range
([_unit, _range, _override] call FUNC(shareInformationRange)) params ["_unit", "_range"];

// find units
private _groups = allGroups select {
    local _x
    && {side _x isEqualTo side _unit}
    && {leader _x distance2d _unit < _range}
    && {behaviour leader _x != "CARELESS"}
    && {_x != group _unit}
};

private _knowsAbout = _unit knowsAbout _target;
// share information
{
    if (!isNull _target) then {
        _x reveal [_target, _knowsAbout min 1];
    };

    if (leader _x distance _unit < (250 min _range)) then {
        _x setBehaviour "COMBAT";
        _x setFormDir ((leader _x) getDir _unit);
    };
} forEach _groups;

[QGVAR(OnInformationShared), [_unit, group _unit, _target, _groups]] call FUNC(eventCallback);

// debug
if (GVAR(debug_functions)) then {
    
    // debug message
    systemchat format ["%1 share information (knows %2 to %3 groups at %4m range)", side _unit, _unit knowsAbout _target, count _groups, round _range];

    // debug marker
    _m = [_unit, [_range,_range], _unit call FUNC(debugMarkerColor), "Border"] call FUNC(zoneMarker);
    //[{deleteMarker _this}, _m, 10] call cba_fnc_waitAndExecute;

    };

// end
true
