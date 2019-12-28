#include "script_component.hpp"
#include "\a3\ui_f\hpp\definedikcodes.inc"
params ["_name", "_data", "_OnComplete", "_OnAbort", "_OnUnload", "_params"];

private _display = (findDisplay 46) createDisplay "RscDisplayEmpty";

_display setVariable [QGVAR(OnAbort), _OnAbort];
_display setVariable [QGVAR(OnUnload), _OnUnload];
_display setVariable [QGVAR(Params), _params];
_display displayAddEventHandler ["KeyDown",  {
    params ["_display", "_dikCode"];
    private _handled = false;
    if (_dikCode == DIK_ESCAPE) then {
        (_display getVariable [QGVAR(Params), []]) call (_display getVariable [QGVAR(OnAbort), {}]); // Call On Close Handler
        _display closeDisplay 1;
        _handled = true;
    };
    _handled;
}];

_display displayAddEventHandler ["Unload",  {
    params ["_display"];
    (_display getVariable [QGVAR(Params), []]) call (_display getVariable [QGVAR(OnClose), {}]); // Call On Close Handler
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
    _label ctrlSetPosition [_basePositionX + PY(CONST_SPACE_HEIGHT), _basePositionY, PX(CONST_WIDTH / 2), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
    _label ctrlSetFontHeight PY(CONST_HEIGHT/2);
    _label ctrlSetText _text;
    _label ctrlSetTooltip _tooltip;
    _label ctrlCommit 0;
    _label;
};

private _fnc_AddTextField = {
    params ["_text", "", ["_tooltip", ""], ["_default", ""]];
    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    [_text, _tooltip] call _fnc_CreateLabel;

    private _textField = _display ctrlCreate ["RscEdit", -1, _globalGroup];
    _textField ctrlSetPosition [_basePositionX + PX(CONST_WIDTH/2), _basePositionY, PX(CONST_WIDTH/2 - CONST_SPACE_HEIGHT), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
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
    _checkbox ctrlSetPosition [_basePositionX + PX(CONST_WIDTH - CONST_HEIGHT - CONST_SPACE_HEIGHT), _basePositionY, PX(CONST_HEIGHT / CONST_ELEMENTDIVIDER), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
    _checkbox ctrlSetTooltip _tooltip;
    _checkbox cbSetChecked _default;
    _checkbox ctrlCommit 0;
    _checkbox;
};

private _fnc_AddDropDown = {
    params ["_text", "", ["_tooltip", ""], ["_values", [], []], ["_default", 0, [0]]];
    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    [_text, _tooltip] call _fnc_CreateLabel;

    private _dropDownField = _display ctrlCreate ["RscCombo", -1, _globalGroup];

    {
        if (_x isEqualType "") then {
            _dropDownField lbAdd _x;
        } else {
            _dropDownField lbAdd ("Not A String " + (str _x));
        };
    } forEach _values;

    _dropDownField ctrlSetPosition [_basePositionX + PX(CONST_WIDTH/2), _basePositionY, PX(CONST_WIDTH/2 - CONST_SPACE_HEIGHT), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
    _dropDownField ctrlSetTooltip _tooltip;
    _dropDownField lbSetCurSel _default;
    _dropDownField ctrlCommit 0;
    _dropDownField;
};

private _fnc_AddSlider = {
    params ["_text", "", ["_tooltip", ""], ["_range", [0, 1]], ["_speed", [0.01, 0.1]], ["_default", 0]];
    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    [_text, _tooltip] call _fnc_CreateLabel;

    private _slider = _display ctrlCreate ["ctrlXSliderH", -1, _globalGroup];
    _slider ctrlSetPosition [_basePositionX + PX(CONST_WIDTH/2), _basePositionY, PX(CONST_WIDTH/2 - CONST_SPACE_HEIGHT), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
    _slider ctrlSetTooltip _tooltip;
    _slider sliderSetRange _range;
    _slider sliderSetSpeed _speed;
    _slider sliderSetPosition _default;
    _slider ctrlCommit 0;
    _slider;
};

private _controls = [];
{
    private _type = toUpper (_x select 1);
    switch (_type) do {
        case ("BOOLEAN");
        case ("BOOL"): {
            _controls pushback [(_x call _fnc_AddBoolean), _type];
        };
        case ("LISTBOX");
        case ("LIST");
        case ("DROPDOWN"): {
            _controls pushBack [(_x call _fnc_AddDropDown), _type];
        };
        case ("SLIDER"): {
            _controls pushBack [(_x call _fnc_AddSlider), _type];
        };
        default {
            _controls pushback [(_x call _fnc_AddTextField), _type];
        };
    };
} forEach _data;

_basePositionY = _basePositionY + PY(CONST_HEIGHT + (CONST_SPACE_HEIGHT*2));

private _cancelButton = _display ctrlCreate ["RscButton", -1, _globalGroup];
_cancelButton ctrlSetText "CANCEL";

_cancelButton ctrlSetPosition [_basePositionX, _basePositionY, PX(CONST_WIDTH / 2), PY(CONST_HEIGHT / 2)];

_cancelButton ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    (_ctrl getVariable [QGVAR(Params), []]) call (_ctrl getVariable [QGVAR(OnAbort), {}]);
    (_ctrl getVariable [QGVAR(Display), displayNull]) closeDisplay 1;
}];
_cancelButton setVariable [QGVAR(OnAbort), _OnAbort];
_cancelButton setVariable [QGVAR(Display), _display];
_cancelButton setVariable [QGVAR(Params), _params];
_cancelButton ctrlCommit 0;

private _okButton = _display ctrlCreate ["RscButton", -1, _globalGroup];
_okButton ctrlSetText "OK";
_okButton ctrlSetPosition [_basePositionX + PX(CONST_WIDTH / 2), _basePositionY, PX(CONST_WIDTH / 2), PY(CONST_HEIGHT / 2)];

_okButton ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _data = [];
    {
        _x params ["_ctrl", "_type"];
        switch (_type) do {
            case ("BOOLEAN");
            case ("BOOL"): {
                _data pushback (cbChecked _ctrl);
            };
            case ("NUMBER"): {
                _data pushback (parseNumber (ctrlText _ctrl));
            };
            case ("INT");
            case ("INTEGER"): {
                _data pushback (round (parseNumber (ctrlText _ctrl)));
            };
            case ("LIST");
            case ("LISTBOX");
            case ("DROPDOWN"): {
                _data pushBack (lbCurSel _ctrl)
            };
            case ("SLIDER"): {
                _data pushBack (sliderPosition _ctrl);
            };
            default {
                _data pushback (ctrlText (_ctrl));
            };
        };
    } forEach (_ctrl getVariable [QGVAR(ControlData), []]);
    [_data, (_ctrl getVariable [QGVAR(Params), []])] call (_ctrl getVariable [QGVAR(OnComplete), {}]);
    (_ctrl getVariable [QGVAR(Display), displayNull]) closeDisplay 1;

}];
_okButton setVariable [QGVAR(OnComplete), _OnComplete];
_okButton setVariable [QGVAR(ControlData), _controls];
_okButton setVariable [QGVAR(Display), _display];
_okButton setVariable [QGVAR(Params), _params];

_okButton ctrlCommit 0;
