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

private _gameCache = uiNamespace getVariable [QGVAR(debug_drawRectCacheGame), []];
private _gameInUse = [];

private _curatorCache = uiNamespace getVariable [QGVAR(debug_drawRectCacheCurator), []];
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
        _curatorInUse pushBack _control;
        _control
    };
    if (!isNull _displayEGSpectator) exitWith {
        if (_spectatorCache isEqualTo []) then {
            _control = _displayEGSpectator ctrlCreate [ "RscStructuredText", -1 ];
            _control ctrlSetBackgroundColor [0, 0, 0, 0.05];
        } else {
            _control = _spectatorCache deleteAt 0;
        };
        _spectatorInUse pushBack _control;
        _control
    };
    if (_gameCache isEqualTo []) then {
        _control = _displayGame ctrlCreate [ "RscStructuredText", -1 ];
        _control ctrlSetBackgroundColor [0, 0, 0, 0.05];
    } else {
        _control = _gameCache deleteAt 0;
    };
    _gameInUse pushBack _control;
    _control
};

private _fnc_debug_drawRect = {
    params ["_pos", "_textData"];
    private _pos2D = worldToScreen _pos;
    if (_pos2D isEqualTo []) exitWith {};
    private _control = call _fnc_getRect;
    _textData pushBack "</t>";

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

private _sideUnknownColor = GVAR(debug_sideColorLUT) get sideUnknown;
private _viewDistance = viewDistance min 250;
private _posCam = positionCameraToWorld [0, 0, 0];
{
    private _unit = _x;
    private _renderPos = getPosATLVisual _unit;
    private _isLeader = _unit isEqualTo (leader _unit);
    private _sideColor = [side (group _unit), false] call BIS_fnc_sideColor;
    if ((_posCam distance _renderPos) <= _viewDistance) then {
        if (!GVAR(debug_drawAllUnitsInVehicles) && {_unit isNotEqualTo (effectiveCommander (vehicle _unit))}) exitWith {};
        private _textData =  ["<t align='bottom' size='%1'>"];

        if (_isLeader) then {
            {
                private _pos2 = getPosATLVisual _x;
                drawLine3D [_renderPos, _pos2, [1, 1, 1, 0.5], 10];
            } forEach ((units _unit) select {alive _x});
            private _color = GVAR(debug_sideColorLUT) getOrDefault [(side _unit), _sideUnknownColor]; // TODO: replace with new Syntax for setting default for hashMap!
            _textData pushBack "<t shadow='0' size='%2' font='PuristaBold' color='" + _color + "'>" + groupId (group _unit) + "</t><br/>";
        };
        _unit getVariable [QGVAR(FSMDangerCauseData), [-1, [0, 0, 0], -1]] params [["_dangerType", -1], ["_pos", [0, 0, 0]], ["_time", -1], ["_currentTarget", objNull]];

        private _targetKnowledge = [];
        private _name = if (_currentTarget isEqualType objNull && {!isNull _currentTarget}) then {
            private _unitIsLocal = local _unit;
            if (_unitIsLocal || !getRemoteSensorsDisabled) then {
                private _knowledge = _unit targetKnowledge _currentTarget;
                private _knowledgePosition = ASLToAGL(_knowledge select 6);
                private _knowledgeAge = _knowledge select 2;
                if (_knowledgeAge isEqualTo time && _unitIsLocal) then {
                    _unit setVariable [QGVAR(debug_LastSeenPos), _knowledgePosition, GVAR(debug_functions)];
                };
                private _lastSeen = _unit getVariable [QGVAR(debug_LastSeenPos), _knowledgePosition];

                // fix when particularly engaging suppressTargets
                if (_knowledgePosition distanceSqr [0, 0, 0] < 1) then {
                    _knowledgePosition = getPosATL _currentTarget;
                    _lastSeen = getPosATL _currentTarget;
                };
                _targetKnowledge append [
                    "<t color='#C7CCC1'>Target Knowledge: <br/>",
                    "    Last Seen: ", _lastSeen, " (", _knowledgeAge toFixed 2, ")<br/>",
                    "    Position Error: ", (_knowledge select 5) toFixed 2, "</t><br/>"
                ];

                if ((side _unit) isNotEqualTo (side _currentTarget)) then {
                    drawLine3D [ASLToATL (aimPos _unit), _knowledgePosition, _sideColor, 6 * (1 - needReload _unit)];
                    drawIcon3D ["\a3\ui_f\data\igui\cfg\targeting\impactpoint_ca.paa", _sideColor, _knowledgePosition, 1, 1, 0, ["Estimated Target Position", ""] select (_knowledgePosition distanceSqr _lastSeen < 1)];

                    if !(_lastSeen isEqualType "") then {
                        private _suppressionFactor = (1 + getSuppression _unit) min 2;
                        drawLine3D [_knowledgePosition, _lastSeen, _sideColor];
                        drawIcon3D ["\a3\ui_f\data\igui\cfg\targeting\hitprediction_ca.paa", _sideColor, _lastSeen, _suppressionFactor, _suppressionFactor, 0, ["Last Seen Position", ""] select (_knowledgePosition distanceSqr _lastSeen < 1)];
                    };
                };

            } else {
                _targetKnowledge pushBack [
                    "<t color'#FFAA00'>RemoteSensors Disabled<br/>",
                    "<t color'#FFAA00'>and Unit Not Local<br/>"
                ];
            };
            //drawLine3D [_renderPos, getPosATLVisual _currentTarget, [1, 0, 0, 1]];  hide direct target lines to reduce clutter ~ nkenny
            [name _currentTarget, "None"] select (isNull _currentTarget);
        } else {
            if (_currentTarget isEqualType []) then {
                drawLine3D [_renderPos, _currentTarget call CBA_fnc_getPos, _sideColor, 6];
                drawIcon3D ["\a3\ui_f\data\igui\cfg\targeting\impactpoint_ca.paa", _sideColor, _currentTarget call CBA_fnc_getPos, 1, 1, 0];
                format ["POS %1", _currentTarget];
            } else {
                format ["N/A"];
            };
        };
        _textData append [
            "Behaviour: ", behaviour _unit, "<br/>",
            "    Current Task: ", _unit getVariable [QGVAR(currentTask), "None"], "<br/>"
        ];
        if (_isLeader) then {
            private _targetCount = count ((_unit targetsQuery [objNull, sideUnknown, "", [], 0]) select {((side _unit) isNotEqualTo (side (_x select 1))) || ((side (_x select 1)) isEqualTo civilian)});
            _textData append [
                "    Current Tactic: ", group _unit getVariable [QGVAR(currentTactic), "None"], "<br/>",
                "    Known Enemies: ", _targetCount, "<br/>",
                "    Group Memory: ", count (group _unit getVariable [QGVAR(groupMemory), []]), "<br/>"
            ];

            {
                drawIcon3D [
                    "\a3\ui_f\data\igui\cfg\simpletasks\types\move_ca.paa",
                    _sideColor,
                    _x,
                    0.7,
                    0.7,
                    0,
                    str (_forEachIndex + 1)
                ];
            } forEach (group _unit getVariable [QGVAR(groupMemory), []]);
        };


        _textData append [
            "<t color='#C7CCC1'>Danger Cause: ", _dangerType call FUNC(debugDangerType), "<br/>"
        ];

        if (_pos isNotEqualTo [0,0,0]) then {
            _textData append [
                "    Danger Pos: ", format ["%1m", round (_unit distance _pos)], "<br/>"
            ];
        };

        _textData append [
            "    Danger Timeout: ", format ["%1s", [(_time - time) toFixed 2, 0] select ((_time - time) < 0)], "</t><br/>",
            "Current Target: ", format ["%1 (%2 visibility)", _name, ([objNull, "VIEW", objNull] checkVisibility [eyePos _unit, _currentTarget call _fnc_getEyePos]) toFixed 1], "<br/>"
        ];

        //_textData append _targetKnowledge;    ~ Hidden to reduce information overload ~ nkenny

        private _currentCommand = currentCommand _unit;
        if (_currentCommand == "") then {_currentCommand = "None";};

        _textData append [
            "Supression: ", getSuppression _unit, "<br/>",
            "Morale: ", morale _unit, "<br/>",
            "Current Command: ", _currentCommand, "<br/>",
            "UnitState: ", getUnitState _unit, "<br/>"
        ];
        if !(_unit checkAIFeature "PATH") then {
            _textData append ["<t color='#FFAA00'>PATH disabled</t>", "<br/>"];
        };
        if !(_unit checkAIFeature "MOVE") then {
            _textData append ["<t color='#FFAA00'>MOVE disabled</t>", "<br/>"];
        };
        if (_unit getVariable [QEGVAR(danger,forceMove), false]) then {
            _textData append ["<t color='#FF4000'>Forced AI</t>", "<br/>"];
        };
        if (fleeing _unit) then {
            _textData append ["<t color='#FFC0CB'>Fleeing</t>", "<br/>"];
        };
        if (isHidden _unit) then {
            _textData append ["<t color='#3631de'>Hidden</t>", "<br/>"];
        };
        if (insideBuilding _unit isEqualTo 1) then {
            _textData append ["<t color='#cc18bc'>Inside</t>", "<br/>"];
        };
        if !(unitReady _unit) then {
            _textData append ["<t color='#FFA500'>Busy</t>", "<br/>"];
        };
        [_renderPos, _textData] call _fnc_debug_drawRect;

        if (GVAR(debug_RenderExpectedDestination)) then {
            (expectedDestination _unit) params ["_pos", "_planingMode", "_forceReplan"];
            if (_unit distance _pos > _viewDistance) exitWith {};
            drawLine3D [_renderPos, _pos, [1, 1, 1, 1]];
            private _iconSize = linearConversion [0, 30, speed _unit, 0.4, 1.2, true];
            drawIcon3D [
                ["\a3\ui_f\data\igui\cfg\simpletasks\types\walk_ca.paa", "\a3\ui_f\data\igui\cfg\simpletasks\types\car_ca.paa"] select (speed _unit > 24),
                [1, 1, 1, 1],
                _pos,
                _iconSize,
                _iconSize,
                0,
                format ["%1m: %2%3", floor (_unit distance _pos), _planingMode, ["", " (ForceReplan)"] select _forceReplan]
            ];
        };
    };
} forEach (allUnits select {!(isPlayer _x)});

_gameCache append _gameInUse;

_spectatorCache append _spectatorInUse;

_curatorCache append _curatorInUse;

uiNamespace setVariable [QGVAR(debug_drawRectCacheGame), _gameCache];
uiNamespace setVariable [QGVAR(debug_drawRectCacheEGSpectator), _spectatorCache];
uiNamespace setVariable [QGVAR(debug_drawRectCacheCurator), _curatorCache];
