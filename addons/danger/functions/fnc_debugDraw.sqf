#include "script_component.hpp"
// DEBUG : Draw Icons and Lines over Units Head
// version 1.01
// by jokoho482
if !(GVAR(debug_Drawing)) exitWith {};
GVAR(debug_TextFactor) = linearConversion [0.55, 0.7, getResolution select 5, 1, 0.85, false];
private _displayGame = findDisplay 46;
private _displayEGSpectator = findDisplay 60492;

{
    _x ctrlSetFade 1;
    _x ctrlCommit 0;
} count GVAR(drawRectCacheGame);

{
    _x ctrlSetFade 1;
    _x ctrlCommit 0;
} count GVAR(drawRectCacheEGSpectator);

private _fnc_getPos = {
    if (_this isEqualType objNull) then {
        (_this modelToWorldVisual (_this selectionPosition "pilot")) vectorAdd [0, 0, 0.4];
    } else {
        _this;
    };
};
private _fnc_getEyePos = {
    if (_this isEqualType objNull) then {
        eyePos _this
    } else {
        _this;
    };
};

private _fnc_dangerModeTypes = {
    params ["_type"];
    switch (_type) do {
        case (1): {
            "Contact";
        };
        case (2): {
            "Hide from tank/air craft";
        };
        case (3): {
            "Manoeuvre";
        };
        case (4): {
            "?"
        };
        case (5): {
            "?"
        };
        case (6): {
            "Call artillery"
        };
    };
};

private _fnc_getRect = {
    private _control = controlNull;
    if (isNull _displayEGSpectator) then {
        if (GVAR(drawRectCacheGame) isEqualTo []) then {
            _control = _displayGame ctrlCreate [ "RscStructuredText", -1 ];
            _control ctrlSetBackgroundColor [0, 0, 0, 0.05];
        } else {
            _control = GVAR(drawRectCacheGame) deleteAt 0;
        };
        GVAR(drawRectInUseGame) pushback _control;
    } else {
        if (GVAR(drawRectCacheEGSpectator) isEqualTo []) then {
            _control = _displayEGSpectator ctrlCreate [ "RscStructuredText", -1 ];
            _control ctrlSetBackgroundColor [0, 0, 0, 0.05];
        } else {
            _control = GVAR(drawRectCacheEGSpectator) deleteAt 0;
        };
        GVAR(drawRectInUseEGSpectator) pushback _control;
    };
    _control
};

private _fnc_DrawRect = {
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
    } count _textData;

    _control ctrlSetStructuredText parseText _text;

    private _w = ctrlTextWidth _control;
    private _h = ctrlTextHeight _control;

    _control ctrlSetPosition [(_pos2D select 0) - _w/2, (_pos2D select 1) - _h, _w, _h];
    _control ctrlSetFade 0;
    _control ctrlCommit 0;
};

{
    private _unit = _x;
    private _headPos = _unit call _fnc_getPos;
    if (((positionCameraToWorld [0, 0, 0]) distance _headPos) <= 1000) then {
    // if (true) then {
        private _textData =  ["<t align='bottom' size='%1'>"];

        if (_unit == leader _unit) then {
            {
                private _pos2 = _x call _fnc_getPos;
                drawLine3D [_headPos, _pos2, [1, 1, 1, 0.5]];
            } count (units _x);
            _textData pushBack "<t size='%2' color='#ff0000'>Group Leader</t><br/>"
        };
        _unit getVariable [QGVAR(FSMDangerCauseData), [-1, [0, 0, 0], -1]] params [["_dangerType", -1], ["_pos", [0, 0, 0]], ["_time", -1], ["_currentTarget", objNull]];

        private _targetKnowledge = [];
        private _name = if (_currentTarget isEqualType objNull && {!isNull _currentTarget}) then {
             private _knowledge = _unit targetKnowledge _currentTarget;
             if (_knowledge select 2 == time) then {
                _unit setVariable [QGVAR(debug_LastSeenPos), _knowledge select 6];
             };
             private _lastSeen = _unit getVariable [QGVAR(debug_LastSeenPos), [0, 0, 0]];
             _targetKnowledge append [
                "Target Knowledge:<br/>",
                "    Last Seen: ", _lastSeen, " (", round ((_knowledge select 2) *100)/100, ")<br/>",
                "    Position Error: ", round ((_knowledge select 5) *100)/100, "<br/>"
            ];

            drawLine3D [_headPos, ASLtoAGL(_knowledge select 6), [0, 1, 0, 0.5]];
            drawIcon3D ["a3\ui_f\data\Map\Markers\System\dummy_ca.paa", [1, 1, 1, 1], ASLtoAGL(_knowledge select 6), 1, 1, 0, "Estimated Target Position"];

            drawLine3D [_headPos, ASLtoAGL(_lastSeen), [0, 0, 1, 0.5]];
            drawIcon3D ["a3\ui_f\data\Map\Markers\System\dummy_ca.paa", [1, 1, 1, 1], ASLtoAGL(_lastSeen), 1, 1, 0, "Last Seen Position"];

            drawLine3D [_headPos, _currentTarget call _fnc_getPos, [1, 0, 0, 1]];
            ["None", name _currentTarget] select (isNull _currentTarget);
        } else {
            _targetKnowledge append [
               "Target Knowledge:<br/>",
               "    Last Seen: N/A (N/A)<br/>",
               "    Position Error: N/A<br/>"
           ];
            if (_currentTarget isEqualType []) then {
                drawLine3D [_headPos, _currentTarget call _fnc_getPos, [1, 0, 0, 1]];
                format ["POS %1", _currentTarget];
            } else {
                format ["N/A"];
            }
        };

        _textData append [
            "Vanilla Behaviour: ", behaviour _unit, "<br/>",
            "Behaviour: ", _unit getVariable [QGVAR(currentTask), "None"], "<br/>"
        ];
        if (_unit == leader _unit) then {
            private _dangeModeData = (group _unit) getVariable [QGVAR(dangerMode), [[], [], true, time]];
            private _queue = (_dangeModeData select 0) apply { _x call _fnc_dangerModeTypes };
            _textData append [
                "Danger Mode Queue: ", [_queue, "None"] select (_queue isEqualTo []), "<br/>",
                "Danger Mode Timeout: ", round ((_dangeModeData select 3) *100)/100, "<br/>"
            ];
        };
        _textData append [
            "Danger Cause: ", _dangerType call FUNC(debugDangerType), "<br/>",
            "    Danger Pos:", _pos, "<br/>",
            "    Danger Until: ", round (_time *100)/100, "<br/>",
            "Current Target: ", _name, "<br/>",
            "Visibility:", round (([objNull, "VIEW", objNull] checkVisibility [eyePos _unit, _currentTarget call _fnc_getEyePos]) *100)/100, "<br/>"
        ];

        _textData append _targetKnowledge;

        private _spotDistance =  round ((_unit skillFinal "spotDistance") *100)/100;
        private _spotTime = round ((_unit skillFinal "spotTime") *100)/100;
        private _targetCount = count ((_unit targetsQuery [objNull, sideUnknown, "", [], 0]) select {!((side _unit) isEqualTo (side (_x select 1))) || ((side (_x select 1)) isEqualTo civilian)});

        _textData append [
            "Supression: ", getSuppression _unit, "<br/>",
            "SpotDistance: ", _spotDistance, "<br/>",
            "SpotTime: ", _spotTime, "<br/>",
            "Enemy QueueSize: ", _targetCount, "<br/>"
        ];
        [_headPos, _textData] call _fnc_DrawRect;

        if (GVAR(RenderExpectedDestination)) then {
            (expectedDestination _x) params ["_pos", "_planingMode", "_forceReplan"];
            drawLine3D [_headPos, _pos, [0, 0, 1, 0.5]];
            drawIcon3D ["a3\ui_f\data\Map\Markers\System\dummy_ca.paa", [1, 1, 1, 1], _pos, 1, 1, 0, format ["Mode: %1 ForceReplan: %2", _planingMode, _forceReplan]];
        };
    };
    false;
} count (allUnits select {!(isPlayer _x)});

GVAR(drawRectCacheGame) = GVAR(drawRectInUseGame);
GVAR(drawRectInUseGame) = [];

GVAR(drawRectCacheEGSpectator) = GVAR(drawRectInUseEGSpectator);
GVAR(drawRectInUseEGSpectator) = [];
