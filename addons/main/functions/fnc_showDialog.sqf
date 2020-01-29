#include "script_component.hpp"
#include "\a3\ui_f\hpp\definedikcodes.inc"
/*
 * Author: joko // Jonas
 * Parses Data from UI Elements from Show Dialog
 *
 * Arguments:
 * 0: Header Text <String>
 * 1: Data <Array<DataTypes>>
 * 2: On Complete <Code>
 * 3: On Abort <Code>
 * 4: On Unload <Code>
 * 5: Passthought Parameters <Any>
 *
 * Return Value:
 * <Array> with Parsed Data
 *
 * Example:
 * ["Banana", [["How Many Bannanas?", "SLIDER", "Bannanna, Bannanna? BANANNAS!!!", [0,10], [1, 2]]], { diag_log _this }, {}, {} ] call Lambs_main_fnc_showDialog;
 *
 * Public: No
*/
params ["_name", "_data", "_OnComplete", "_OnAbort", "_OnUnload", "_params"];


private _displayGame = findDisplay 46;
private _displayEGSpectator = findDisplay 60492;
private _displayCurator = findDisplay 312;

private _display = displayNull;

if !(isNull _displayEGSpectator) then {
    _display = _displayEGSpectator createDisplay "RscDisplayEmpty";
} else {
    if !(isNull _displayCurator) then {
        _display = _displayCurator createDisplay "RscDisplayEmpty";
    } else {
        _display = _displayGame createDisplay "RscDisplayEmpty";
    };
};
if (isNull _display) exitWith {}; // if we hit this something went wrong!
_display displayAddEventHandler ["KeyDown",  {
    params ["_display", "_dikCode"];
    private _handled = false;
    if (_dikCode == DIK_ESCAPE) then {
        (_display getVariable [QGVAR(Params), []]) call (_display getVariable [QGVAR(OnAbort), {}]); // Call On Close Handler
        _display closeDisplay 1;
        _handled = true;
    };
    if (_dikCode == DIK_NUMPADENTER || _dikCode == DIK_RETURN) then {
        private _data = _display call FUNC(parseData);
        [_data, (_display getVariable [QGVAR(Params), []])] call (_display getVariable [QGVAR(OnComplete), {}]);
        _display closeDisplay 1;
        _handled = true;
    };
    _handled;
}];

_display displayAddEventHandler ["Unload",  {
    params ["_display"];
    (_display getVariable [QGVAR(Params), []]) call (_display getVariable [QGVAR(OnClose), {}]); // Call On Close Handler
}];

private _height = ((count _data) + 1) * (PY(CONST_HEIGHT + CONST_SPACE_HEIGHT));

private _basePositionX = 0.5 - (PX(CONST_WIDTH) / 2);
private _basePositionY = 0.5 - (_height / 2);

private _globalGroup = _display ctrlCreate ["RscText", -1];
_globalGroup ctrlSetBackgroundColor BACKGROUND_RGB(0.8);
_globalGroup ctrlSetPosition [_basePositionX, 0.5 - (_height / 2), PX(CONST_WIDTH), _height];
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
    _label ctrlSetPosition [_basePositionX + PY(CONST_SPACE_HEIGHT), _basePositionY + PY(CONST_HEIGHT / 2), PX(CONST_WIDTH / 2), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
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
    _textField ctrlSetPosition [_basePositionX + PX(CONST_WIDTH/2), _basePositionY + PY(CONST_HEIGHT / 2), PX(CONST_WIDTH/2 - CONST_SPACE_HEIGHT), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
    _textField ctrlSetTooltip _tooltip;
    if !(_default isEqualType "") then {
        _default = str _default;
    };
    _textField ctrlSetText _default;
    _textField ctrlCommit 0;
    _textField;
};

private _fnc_AddBoolean = {
    params ["_text", "", ["_tooltip", ""], ["_default", false, [false]]];
    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    [_text, _tooltip] call _fnc_CreateLabel;

    private _checkbox = _display ctrlCreate ["RscCheckBox", -1, _globalGroup];
    _checkbox ctrlSetPosition [_basePositionX + PX(CONST_WIDTH - CONST_HEIGHT + CONST_SPACE_HEIGHT), _basePositionY + PY(CONST_HEIGHT / 2), PX(CONST_HEIGHT / CONST_ELEMENTDIVIDER), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
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

    _dropDownField ctrlSetPosition [_basePositionX + PX(CONST_WIDTH/2), _basePositionY + PY(CONST_HEIGHT / 2) , PX(CONST_WIDTH/2 - CONST_SPACE_HEIGHT), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
    _dropDownField ctrlSetTooltip _tooltip;
    _dropDownField lbSetCurSel _default;
    _dropDownField ctrlCommit 0;
    _dropDownField;
};

private _fnc_AddSlider = {
    params ["_text", "", ["_tooltip", ""], ["_range", [0, 1]], ["_speed", [0.01, 0.1]], "_default"];
    // if no Default is Given we use the middle of the Range input
    if (isNil "_default") then {
        _default = linearConversion [0, 1, 0.5, _range select 0, _range select 1, true];
    };
    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    [_text, _tooltip] call _fnc_CreateLabel;

    private _slider = _display ctrlCreate ["ctrlXSliderH", -1, _globalGroup];
    _slider ctrlSetPosition [_basePositionX + PX(CONST_WIDTH/2), _basePositionY + PY(CONST_HEIGHT / 2), PX(CONST_WIDTH/2 - CONST_SPACE_HEIGHT), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
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
    private _display = ctrlParent _ctrl;
    (_display getVariable [QGVAR(Params), []]) call (_display getVariable [QGVAR(OnAbort), {}]);
    _display closeDisplay 1;
}];
_cancelButton ctrlCommit 0;

private _okButton = _display ctrlCreate ["RscButton", -1, _globalGroup];
_okButton ctrlSetText "OK";
_okButton ctrlSetPosition [_basePositionX + PX(CONST_WIDTH / 2), _basePositionY, PX(CONST_WIDTH / 2), PY(CONST_HEIGHT / 2)];

_okButton ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _display = ctrlParent _ctrl;

    private _data = _display call FUNC(parseData);
    [_data, (_display getVariable [QGVAR(Params), []])] call (_display getVariable [QGVAR(OnComplete), {}]);
    _display closeDisplay 1;
}];

_display setVariable [QGVAR(OnComplete), _OnComplete];
_display setVariable [QGVAR(ControlData), _controls];
_display setVariable [QGVAR(OnAbort), _OnAbort];
_display setVariable [QGVAR(OnUnload), _OnUnload];
_display setVariable [QGVAR(Params), _params];

_okButton ctrlCommit 0;
