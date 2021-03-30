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
 * [bob, angryJoe, 350, false] call lambs_main_fnc_doShareInformation;
 *
 * Public: No
*/
params ["_unit", ["_target", objNull], ["_range", 350], ["_override", false]];

// nil or captured
if (
    GVAR(radioDisabled)
    || {!(_unit call FUNC(isAlive))}
    || {_unit getVariable ["ace_captives_isHandcuffed", false]}
    || {_unit getVariable ["ace_captives_issurrendering", false]}
) exitWith {false};

// no target
if (isNull _target) then {
    _target = _unit findNearestEnemy _unit;
};

// custom handlers
private _handlersReturn = true;
{
    private _handlerResult = [_unit, _target, _range, _override] call _x;
    if (!isNil _handlerResult && _handlerResult isEqualTo false) exitWith {_handlersReturn = false};
} forEach GVAR(shareHandlers);
if (!_handlersReturn) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target, GVAR(debug_functions)];
//_unit setVariable [QGVAR(currentTask), "Share Information", GVAR(debug_functions)]; // do not update task -- sharing information is secondary info ~ nkenny

// range
([_unit, _range, _override] call FUNC(getShareInformationParams)) params ["_unit", "_range"];

// find units
private _groups = allGroups select {
    private _leader = leader _x;
    _leader distance2D _unit < _range
    && {simulationEnabled (vehicle _leader)}
    && {[side _x, side _unit] call BIS_fnc_sideIsFriendly}
    && {behaviour _leader != "CARELESS"}
    && {_x != group _unit}
};

{
    // share information
    if !(isNull _target) then {
        private _knowsAbout = _unit knowsAbout _target;
        [_x, [_target, _knowsAbout min GVAR(maxRevealValue)]] remoteExec ["reveal", leader _x];
    };
} forEach _groups;

[QGVAR(OnInformationShared), [_unit, group _unit, _target, _groups]] call FUNC(eventCallback);

// play animation
if (
    RND(0.2)
    && {_range > 100}
    && {_unit distance2D _target > 4}
) then {
    [_unit, "HandSignalRadio"] call FUNC(doGesture);
};

// debug
if (EGVAR(main,debug_functions)) then {
    // debug message
    ["%1 share information (%2 knows %3 to %4 groups @ %5m range)", side _unit, name _unit, (_unit knowsAbout _target) min 1, count _groups, round _range] call FUNC(debugLog);

    // debug marker
    private _zm = [_unit, [_range,_range], _unit call FUNC(debugMarkerColor), "Border"] call FUNC(zoneMarker);
    private _markers = [_zm];

    // enemy units
    {
        private _m = [_unit getHideFrom _x, "", _x call FUNC(debugMarkerColor), "mil_triangle"] call FUNC(dotMarker);
        _m setMarkerSizeLocal [0.5, 0.5];
        _m setMarkerDirLocal (getDir _x);
        _markers pushBack _m;
    } foreach ((units _target) select {_unit knowsAbout _x > 0});

    // friendly units
    {
        private _m = [_unit getHideFrom _x, "", _x call FUNC(debugMarkerColor), "mil_triangle"] call FUNC(dotMarker);
        _m setMarkerSizeLocal [0.5, 0.5];
        _m setMarkerDirLocal (getDir _x);
        _markers pushBack _m;
    } foreach units _unit;
    [{{deleteMarker _x;true} count _this;}, _markers, 60] call CBA_fnc_waitAndExecute;
};

// end
true
