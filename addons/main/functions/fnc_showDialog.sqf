#include "script_component.hpp"
#include "\a3\ui_f\hpp\definedikcodes.inc"
params ["_name", "_data", "_OnComplete", "_OnAbort", "_OnUnload"];

private _display = (findDisplay 46) createDisplay "RscDisplayEmpty";

_display setVariable [QGVAR(OnAbort), _OnAbort];
_display setVariable [QGVAR(OnUnload), _OnUnload];

_display displayAddEventHandler ["KeyDown",  {
    params ["_display", "_dikCode"];
    private _handled = false;
    if (_dikCode == DIK_ESCAPE) then {
        call (_display getVariable [QGVAR(OnAbort), {}]); // Call On Close Handler
        _display closeDisplay 1;
        _handled = true;
    };
    _handled;
}];

_display displayAddEventHandler ["Unload",  {
    params ["_display"];
    call (_display getVariable [QGVAR(OnClose), {}]); // Call On Close Handler
}];

private _heigth = ((count _data) + 1) * (PY(CONST_HEIGHT + CONST_SPACE_HEIGHT));

private _basePositionX = 0.5 - (PX(CONST_WIDTH) / 2);
private _basePositionY = 0.5 - (_heigth / 2);

private _globalGroup = _display ctrlCreate ["RscText", -1];
_globalGroup ctrlSetBackgroundColor BACKGROUND_RGB(0.8);
_globalGroup ctrlSetPosition [_basePositionX, 0.5 - (_heigth / 2), PX(CONST_WIDTH), _heigth];
_globalGroup ctrlCommit 0;

private _header = _display ctrlCreate ["RscText", -1, _globalGroup];
_header ctrlSetText _name;
_header ctrlSetFontHeight PY(CONST_HEIGHT);
_header ctrlSetPosition [0.5 - (PX(CONST_WIDTH / 2)), _basePositionY, PX(CONST_WIDTH), PY(5)];
_header ctrlSetBackgroundColor COLOR_RGBA;
_header ctrlCommit 0;

private _fnc_CreateLabel = {
    params ["_text", ["_tooltip", ""]];
    private _label = _display ctrlCreate ["RscText", -1, _globalGroup];
    _label ctrlSetPosition [_basePositionX + PY(CONST_SPACE_HEIGHT), _basePositionY, PX(CONST_WIDTH / 2), PY(CONST_HEIGHT)];
    _label ctrlSetFontHeight PY(CONST_HEIGHT/2);
    _label ctrlSetText _text;
    _label ctrlSetTooltip _tooltip;
    _label ctrlCommit 0;
};

private _fnc_AddTextField = {
    params ["_text", "", ["_tooltip", ""], ["_default", ""]];
    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    [_text, _tooltip] call _fnc_CreateLabel;

    private _textField = _display ctrlCreate ["RscEdit", -1, _globalGroup];
    _textField ctrlSetPosition [_basePositionX + PX(CONST_WIDTH/2), _basePositionY, PX(CONST_WIDTH/2 - CONST_SPACE_HEIGHT), PY(CONST_HEIGHT)];
    _textField ctrlSetTooltip _tooltip;
    _textField ctrlSetText _default;
    _textField ctrlCommit 0;
    _textField;
};

private _fnc_AddBoolean = {
    params ["_text", "", ["_tooltip", ""], ["_default", false, [false]]];
    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    [_text, _tooltip] call _fnc_CreateLabel;

    private _checkbox = _display ctrlCreate ["RscCheckBox", -1, _globalGroup];
    _checkbox ctrlSetPosition [_basePositionX + PX(CONST_WIDTH - CONST_HEIGHT - CONST_SPACE_HEIGHT), _basePositionY, PX(CONST_HEIGHT), PY(CONST_HEIGHT)];
    _checkbox ctrlSetTooltip _tooltip;
    _checkbox cbSetChecked _default;
    _checkbox ctrlCommit 0;
    _checkbox;
};

private _controls = [];
{
    switch (toUpper (_x select 1)) do {
        case ("BOOLEAN");
        case ("BOOL"): {
            _controls pushback [(_x call _fnc_AddBoolean), _x select 1];
        };
        default {
            _controls pushback [(_x call _fnc_AddTextField), _x select 1];
        };
    };
} forEach _data;

_basePositionY = _basePositionY + PY(CONST_HEIGHT + (CONST_SPACE_HEIGHT*2));

private _cancelButton = _display ctrlCreate ["RscButton", -1, _globalGroup];
_cancelButton ctrlSetText "CANCEL";

_cancelButton ctrlSetPosition [_basePositionX, _basePositionY, PX(CONST_WIDTH / 2), PY(CONST_HEIGHT / 2)];

_cancelButton ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    call (_ctrl getVariable [QGVAR(OnAbort), {}]);
    (_ctrl getVariable [QGVAR(Display), displayNull]) closeDisplay 1;
}];
_cancelButton setVariable [QGVAR(OnAbort), _OnAbort];
_cancelButton setVariable [QGVAR(Display), _display];

_cancelButton ctrlCommit 0;

private _okButton = _display ctrlCreate ["RscButton", -1, _globalGroup];
_okButton ctrlSetText "OK";
_okButton ctrlSetPosition [_basePositionX + PX(CONST_WIDTH / 2), _basePositionY, PX(CONST_WIDTH / 2), PY(CONST_HEIGHT / 2)];

_okButton ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _data = [];
    {
        switch (_x select 1) do {
            case ("BOOLEAN");
            case ("BOOL"): {
                _data pushback (cbChecked (_x select 0));
            };
            case ("NUMBER"): {
                _data pushback (parseNumber (ctrlText (_x select 0)));
            };
            case ("INT");
            case ("INTEGER"): {
                _data pushback (round (parseNumber (ctrlText (_x select 0))));
            };
            default {
                _data pushback (ctrlText (_x select 0));
            };
        };
    } forEach (_ctrl getVariable [QGVAR(ControlData), {}]);
    _data call (_ctrl getVariable [QGVAR(OnComplete), {}]);
    (_ctrl getVariable [QGVAR(Display), displayNull]) closeDisplay 1;

}];
_okButton setVariable [QGVAR(OnComplete), _OnComplete];
_okButton setVariable [QGVAR(ControlData), _controls];
_okButton setVariable [QGVAR(Display), _display];

_okButton ctrlCommit 0;