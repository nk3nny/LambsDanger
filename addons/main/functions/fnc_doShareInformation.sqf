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

// range
([_unit, _range, _override] call FUNC(getShareInformationParams)) params ["_newUnit", "_newRange", "_radio"];

// custom handlers
private _stopShare = false;
{
    private _callbackResult = [_unit, _target, _range, _override, _newUnit, _newRange, _radio] call _x;
    if (!(isNil "_callbackResult") && {_callbackResult isEqualTo true}) exitWith {_stopShare = true};
} forEach GVAR(shareHandlers);
if (_stopShare) exitWith {false};

_unit setVariable [QGVAR(currentTarget), _target, GVAR(debug_functions)];
//_unit setVariable [QGVAR(currentTask), "Share Information", GVAR(debug_functions)]; // do not update task -- sharing information is secondary info ~ nkenny

// find units
private _group = group _newUnit;
private _side = side _group;
private _groups = allGroups select {
    private _leader = leader _x;
    _leader distance2D _newUnit < _newRange
    && {simulationEnabled (vehicle _leader)}
    && {((side _x) getFriend _side) > 0.6}
    && {(behaviour _leader) isNotEqualTo "CARELESS"}
    && {!isPlayer _leader}
    && {_x isNotEqualTo _group}
};

// share information
if !(isNull _target) then {
    private _knowsAbout = (_newUnit knowsAbout _target) min GVAR(maxRevealValue);
    {
        [_x, [_target, _knowsAbout]] remoteExec ["reveal", leader _x];
    } forEach (_groups select {_newUnit distance2D (leader _x) < GVAR(combatShareRange)});
};

[QGVAR(OnInformationShared), [_newUnit, group _newUnit, _target, _groups]] call FUNC(eventCallback);

// play animation
if (
    RND(0.2)
    && {_newRange > 100}
    && {_newUnit distance2D _target > 4}
) then {
    [_newUnit, "HandSignalRadio"] call FUNC(doGesture);
};

// debug
if (EGVAR(main,debug_functions)) then {
    // debug message
    ["%1 share information (%2 knows %3 to %4 groups @ %5m range)", side _newUnit, name _newUnit, (_newUnit knowsAbout _target) min GVAR(maxRevealValue), count _groups, round _range] call FUNC(debugLog);

    // debug marker
    private _zm = [_newUnit, [_newRange, _newRange], _newUnit call FUNC(debugMarkerColor), "Border"] call FUNC(zoneMarker);
    private _zmm = [_newUnit, [_newRange min GVAR(combatShareRange), _newRange min GVAR(combatShareRange)], _newUnit call FUNC(debugMarkerColor), "SolidBorder"] call FUNC(zoneMarker);
    _zmm setMarkerAlphaLocal 0.3;
    private _markers = [_zm, _zmm];

    // enemy units
    {
        private _m = [_unit getHideFrom _x, "", _x call FUNC(debugMarkerColor), "mil_triangle"] call FUNC(dotMarker);
        _m setMarkerSizeLocal [0.5, 0.5];
        _m setMarkerDirLocal (getDir _x);
        _m setMarkerTextLocal str (_unit knowsAbout _x);
        _markers pushBack _m;
    } forEach ((units _target) select {_unit knowsAbout _x > 0});

    // friendly units
    {
        private _m = [_x, "", _x call FUNC(debugMarkerColor), "mil_triangle"] call FUNC(dotMarker);
        _m setMarkerSizeLocal [0.5, 0.5];
        _m setMarkerDirLocal (getDir _x);
        _markers pushBack _m;
    } forEach units _unit;
    [{{deleteMarker _x;true} count _this;}, _markers, 60] call CBA_fnc_waitAndExecute;
};

// end
true
