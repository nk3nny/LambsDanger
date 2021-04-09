#include "script_component.hpp"
/*
 * Author: jokoho482
 * Enables Draw Icons and Lines over units head containing debug information
 *
 * Arguments:
 * none
 *
 * Return Value:
 * none
 *
 * Example:
 * [] call lambs_main_fnc_debugDraw;
 *
 * Public: No
*/

if !(GVAR(debug_Drawing)) exitWith {};
if (is3DEN) exitWith {};

private _fnc_clearControls = {
    params ["_variable"];
    private _delete = false;
    private _data = uiNamespace getVariable _variable;
    {
        if (isNull _x) then {
            _delete = true;
        } else {
            _x ctrlSetFade 1;
            _x ctrlCommit 0;
        };
    } forEach _data;
    if (_delete) then {
        uiNamespace setVariable [_variable, _data - [controlNull]];
    };
};

private _displayGame = findDisplay 46;
private _displayEGSpectator = findDisplay 60492;
private _displayCurator = findDisplay 312;

QGVAR(debug_drawRectCacheGame) call _fnc_clearControls;
QGVAR(debug_drawRectCacheCurator) call _fnc_clearControls;
QGVAR(debug_drawRectCacheEGSpectator) call _fnc_clearControls;

private _gameCache = uiNamespace getvariable [QGVAR(debug_drawRectCacheGame), []];
private _gameInUse = [];

private _curatorCache = uiNamespace getvariable [QGVAR(debug_drawRectCacheCurator), []];
private _curatorInUse = [];

private _spectatorCache = uiNamespace getVariable [QGVAR(debug_drawRectCacheEGSpectator), []];
private _spectatorInUse = [];

private _fnc_getEyePos = {
    if (_this isEqualType objNull) then {
        eyePos _this
    } else {
        _this;
    };
};

private _fnc_getRect = {
    private _control = controlNull;
    if (!isNull _displayCurator) exitWith {
        if (_curatorCache isEqualTo []) then {
            _control = _displayCurator ctrlCreate [ "RscStructuredText", -1 ];
            _control ctrlSetBackgroundColor [0, 0, 0, 0.05];
        } else {
            _control = _curatorCache deleteAt 0;
        };
        _curatorInUse pushback _control;
        _control
    };
    if (!isNull _displayEGSpectator) exitWith {
        if (_spectatorCache isEqualTo []) then {
            _control = _displayEGSpectator ctrlCreate [ "RscStructuredText", -1 ];
            _control ctrlSetBackgroundColor [0, 0, 0, 0.05];
        } else {
            _control = _spectatorCache deleteAt 0;
        };
        _spectatorInUse pushback _control;
        _control
    };
    if (_gameCache isEqualTo []) then {
        _control = _displayGame ctrlCreate [ "RscStructuredText", -1 ];
        _control ctrlSetBackgroundColor [0, 0, 0, 0.05];
    } else {
        _control = _gameCache deleteAt 0;
    };
    _gameInUse pushback _control;
    _control
};

private _fnc_debug_drawRect = {
    params ["_pos", "_textData"];
    private _pos2D = worldToScreen _pos;
    if (_pos2D isEqualTo []) exitWith {};
    private _control = call _fnc_getRect;
    _textData pushback "</t>";

    private _text = "";
    {
        private _str = _x;
        if !(_str isEqualType "") then {
            _str = str _x;
        };
        _text = _text + format [_str, GVAR(debug_TextFactor) * 1, GVAR(debug_TextFactor) * 1.5];
    } forEach _textData;

    _control ctrlSetStructuredText parseText _text;

    private _w = ctrlTextWidth _control;
    private _h = ctrlTextHeight _control;

    _control ctrlSetPosition [(_pos2D select 0) - _w/2, (_pos2D select 1) - _h, _w, _h];
    _control ctrlSetFade 0;
    _control ctrlCommit 0;

};

{
    private _unit = _x;
    private _headPos = _unit call CBA_fnc_getPos;
    if (((positionCameraToWorld [0, 0, 0]) distance _headPos) <= 1000) then {
    // if (true) then {
        private _textData =  ["<t align='bottom' size='%1'>"];

        if (_unit == leader _unit) then {
            {
                private _pos2 = _x call CBA_fnc_getPos;
                drawLine3D [_headPos, _pos2, [1, 1, 1, 0.5]];
            } forEach (units _unit);
            _textData pushBack "<t size='%2' color='#ff0000'>Group Leader</t><br/>"
        };
        _unit getVariable [QGVAR(FSMDangerCauseData), [-1, [0, 0, 0], -1]] params [["_dangerType", -1], ["_pos", [0, 0, 0]], ["_time", -1], ["_currentTarget", objNull]];

        private _targetKnowledge = [];
        private _name = if (_currentTarget isEqualType objNull && {!isNull _currentTarget}) then {
            private _knowledge = _unit targetKnowledge _currentTarget;
            if (_knowledge select 2 == time && local _unit) then {
                _unit setVariable [QGVAR(debug_LastSeenPos), _knowledge select 6, GVAR(debug_functions)];
            };
            private _lastSeen = _unit getVariable [QGVAR(debug_LastSeenPos), [0, 0, 0]];
            _targetKnowledge append [
                "<t color='#C7CCC1'>Target Knowledge: <br/>",
                "    Last Seen: ", _lastSeen, " (", round ((_knowledge select 2) *100)/100, ")<br/>",
                "    Position Error: ", round ((_knowledge select 5) *100)/100, "</t><br/>"
            ];

            drawLine3D [_headPos, ASLtoAGL(_knowledge select 6), [0, 1, 0, 0.5]];
            drawIcon3D ["a3\ui_f\data\Map\Markers\System\dummy_ca.paa", [1, 1, 1, 1], ASLtoAGL(_knowledge select 6), 1, 1, 0, "Estimated Target Position"];

            drawLine3D [_headPos, ASLtoAGL(_lastSeen), [0, 0, 1, 0.5]];
            drawIcon3D ["a3\ui_f\data\Map\Markers\System\dummy_ca.paa", [1, 1, 1, 1], ASLtoAGL(_lastSeen), 1, 1, 0, "Last Seen Position"];

            drawLine3D [_headPos, _currentTarget call CBA_fnc_getPos, [1, 0, 0, 1]];
            [name _currentTarget, "None"] select (isNull _currentTarget);
        } else {
            if (_currentTarget isEqualType []) then {
                drawLine3D [_headPos, _currentTarget call CBA_fnc_getPos, [1, 0, 0, 1]];
                format ["POS %1", _currentTarget];
            } else {
                format ["N/A"];
            }
        };

        _textData append [
            "Behaviour: ", behaviour _unit, "<br/>",
            "    Current Task: ", _unit getVariable [QGVAR(currentTask), "None"], "<br/>"
        ];
        if (_unit == leader _unit) then {
            private _targetCount = count ((_unit targetsQuery [objNull, sideUnknown, "", [], 0]) select {((side _unit) isNotEqualTo (side (_x select 1))) || ((side (_x select 1)) isEqualTo civilian)});
            _textData append [
                "    Current Tactic: ", group _unit getVariable [QGVAR(currentTactic), "None"], "<br/>",
                "    Known enemies: ", _targetCount, "<br/>",
                "    Group memory: ", count (group _unit getVariable [QGVAR(groupMemory), []]), "<br/>"
            ];
        };
        _textData append [
            "<t color='#C7CCC1'>Danger Cause: ", _dangerType call FUNC(debugDangerType), "<br/>",
            "    Danger Pos: ", format ["%1m", round (_unit distance _pos)], "<br/>",
            "    Danger Timeout: ", format ["%1s", [round (_time - time), 0] select ((_time - time) < 0)], "</t><br/>",
            "Current Target: ", format ["%1 (%2 visiblity)", _name, [objNull, "VIEW", objNull] checkVisibility [eyePos _unit, _currentTarget call _fnc_getEyePos]], "<br/>"
        ];

        _textData append _targetKnowledge;


        _textData append [
            "Supression: ", getSuppression _unit, "<br/>",
            "Morale: ", morale _unit, "<br/>"
        ];
        [_headPos, _textData] call _fnc_debug_drawRect;

        if (GVAR(debug_RenderExpectedDestination)) then {
            (expectedDestination _unit) params ["_pos", "_planingMode", "_forceReplan"];
            drawLine3D [_headPos, _pos, [0, 0, 1, 0.5]];
            drawIcon3D ["a3\ui_f\data\Map\Markers\System\dummy_ca.paa", [1, 1, 1, 1], _pos, 1, 1, 0, format ["Move: %1%2", _planingMode, if (_forceReplan) then {" (ForceReplan)"} else {""}]];
        };
    };
} forEach (allUnits select {!(isPlayer _x)});

_gameCache append _gameInUse;

_spectatorCache append _spectatorInUse;

_curatorCache append _curatorInUse;

uiNamespace setVariable [QGVAR(debug_drawRectCacheGame), _gameCache];
uiNamespace setVariable [QGVAR(debug_drawRectCacheEGSpectator), _spectatorCache];
uiNamespace setVariable [QGVAR(debug_drawRectCacheCurator), _curatorCache];
