#include "script_component.hpp"
#include "\a3\ui_f\hpp\defineDIKCodes.inc"
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


if (!createDialog QGVAR(display)) exitWith {
    false
};
private _display = uiNamespace getVariable QGVAR(display);

if (isNull _display) exitWith {}; // if we hit this something went wrong!
_display displayAddEventHandler ["KeyDown",  {
    params ["_display", "_dikCode"];
    private _handled = false;
    if (_dikCode == DIK_ESCAPE) then {
        (_display getVariable [QGVAR(Params), []]) call (_display getVariable [QGVAR(OnAbort), {}]); // Call On OnAbort Handler
        closeDialog 2;
        _handled = true;
    };
    if (_dikCode == DIK_NUMPADENTER || _dikCode == DIK_RETURN) then {
        private _data = _display call FUNC(parseData);
        [_data, (_display getVariable [QGVAR(Params), []])] call (_display getVariable [QGVAR(OnComplete), {}]);
        closeDialog 1;
        _handled = true;
    };
    _handled;
}];

_display displayAddEventHandler ["Unload",  {
    params ["_display"];
    (_display getVariable [QGVAR(Params), []]) call (_display getVariable [QGVAR(OnUnload), {}]); // Call On OnUnload Handler
}];

private _height = ((count _data) + 1) * (PY(CONST_HEIGHT + CONST_SPACE_HEIGHT));

private _basePositionX = 0.5 - (PX(CONST_WIDTH) / 2);
private _basePositionY = 0.5 - (_height / 2);

private _globalGroup = _display ctrlCreate ["RscText", -1];
_globalGroup ctrlSetBackgroundColor BACKGROUND_RGB(0.8);
_globalGroup ctrlSetPosition [_basePositionX, 0.5 - (_height / 2), PX(CONST_WIDTH), _height];
_globalGroup ctrlCommit 0;

if (isLocalized _name) then {
    _name = localize _name;
};

private _header = _display ctrlCreate ["RscText", -1, _globalGroup];
_header ctrlSetText _name;
_header ctrlSetFontHeight PY(CONST_HEIGHT);
_header ctrlSetPosition [0.5 - (PX(CONST_WIDTH / 2)), _basePositionY, PX(CONST_WIDTH), PY(5)];
_header ctrlSetBackgroundColor COLOR_RGBA;
_header ctrlCommit 0;

private _fnc_CreateLabel = {
    params ["_text", ["_tooltip", ""]];
    if (isLocalized _text) then {
        _text = localize _text;
    };
    if (isLocalized _tooltip) then {
        _tooltip = localize _tooltip;
    };
    private _label = _display ctrlCreate ["RscText", -1, _globalGroup];
    _label ctrlSetPosition [_basePositionX + PX(CONST_SPACE_HEIGHT), _basePositionY + PY(CONST_HEIGHT / 2), PX(CONST_WIDTH / 2), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
    _label ctrlSetFontHeight PY(CONST_HEIGHT/2);
    _label ctrlSetText _text;
    _label ctrlSetTooltip _tooltip;
    _label ctrlCommit 0;
    _label;
};

private _fnc_DescriptionField = {
    params [["_text", "", ["", text "",[]]]];
    if (_text isEqualType []) then {
        {
            if (_x isEqualType "" && {isLocalized _x}) then {
                _text set [_forEachIndex, localize _x];
            };
        } forEach _text;
        _text = formatText _text;
    } else {
        if (_text isEqualType "" && {isLocalized _text}) then {
            _text = localize _text;
        };
    };
    if (_text isEqualType "") then {
        _text = parseText _text;
    };
    private _textField = _display ctrlCreate ["RscStructuredText", -1, _globalGroup];
    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    _textField ctrlSetPosition [_basePositionX + PX(CONST_SPACE_HEIGHT), _basePositionY + PY(CONST_SPACE_HEIGHT/2), PX(CONST_WIDTH - CONST_SPACE_HEIGHT * 2), PY(CONST_HEIGHT - (CONST_SPACE_HEIGHT/2))];
    _textField ctrlSetStructuredText _text;
    _textField ctrlCommit 0;
    _textField;
};

private _fnc_AddTextField = {
    params ["_text", "", ["_tooltip", ""], ["_default", ""]];
    if (isLocalized _tooltip) then {
        _tooltip = localize _tooltip;
    };
    private _cacheName = format ["lambs_%1_%2", _name, _text];
    _default = GVAR(ChooseDialogSettingsCache) getVariable [_cacheName, _default];
    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    [_text, _tooltip] call _fnc_CreateLabel;

    private _textField = _display ctrlCreate ["RscEdit", -1, _globalGroup];
    _textField ctrlSetPosition [_basePositionX + PX(CONST_WIDTH/2), _basePositionY + PY(CONST_HEIGHT / 2), PX(CONST_WIDTH/2 - CONST_SPACE_HEIGHT), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
    _textField ctrlSetTooltip _tooltip;
    if !(_default isEqualType "") then {
        _default = str _default;
    };
    _textField ctrlSetText _default;
    _textField setVariable [QGVAR(CacheName), _cacheName];
    _textField ctrlCommit 0;
    _textField;
};

private _fnc_AddBoolean = {
    params ["_text", "", ["_tooltip", ""], ["_default", false, [false]]];
    if (isLocalized _tooltip) then {
        _tooltip = localize _tooltip;
    };
    private _cacheName = format ["lambs_%1_%2", _name, _text];
    _default = GVAR(ChooseDialogSettingsCache) getVariable [_cacheName, _default];

    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    [_text, _tooltip] call _fnc_CreateLabel;

    private _checkbox = _display ctrlCreate ["RscCheckBox", -1, _globalGroup];
    _checkbox ctrlSetPosition [_basePositionX + PX(CONST_WIDTH - CONST_HEIGHT + CONST_SPACE_HEIGHT), _basePositionY + PY(CONST_HEIGHT / 2), PX(CONST_HEIGHT / CONST_ELEMENTDIVIDER), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
    _checkbox ctrlSetTooltip _tooltip;
    _checkbox cbSetChecked _default;
    _checkbox setVariable [QGVAR(CacheName), _cacheName];
    _checkbox ctrlCommit 0;
    _checkbox;
};

private _fnc_AddDropDown = {
    params ["_text", "", ["_tooltip", ""], ["_values", [], [[]]], ["_default", 0, [0]]];
    if (isLocalized _tooltip) then {
        _tooltip = localize _tooltip;
    };
    private _cacheName = format ["lambs_%1_%2", _name, _text];
    _default = GVAR(ChooseDialogSettingsCache) getVariable [_cacheName, _default];

    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    [_text, _tooltip] call _fnc_CreateLabel;

    private _dropDownField = _display ctrlCreate ["RscCombo", -1, _globalGroup];

    {
        private _str = if (_x isEqualType "") then {
            if (isLocalized _x) then {
                localize _x;
            } else {
                _x;
            };
        } else {
            str _x;
        };
        _dropDownField lbAdd _str;

    } forEach _values;

    _dropDownField ctrlSetPosition [_basePositionX + PX(CONST_WIDTH/2), _basePositionY + PY(CONST_HEIGHT / 2) , PX(CONST_WIDTH/2 - CONST_SPACE_HEIGHT), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
    _dropDownField ctrlSetTooltip _tooltip;
    _dropDownField lbSetCurSel _default;
    _dropDownField setVariable [QGVAR(CacheName), _cacheName];
    _dropDownField ctrlCommit 0;
    _dropDownField;
};

private _fnc_AddSlider = {
    #define __SLIDER_EDIT_SIZE__ 16
    params ["_text", "", ["_tooltip", ""], ["_range", [0, 1]], ["_speed", [0.01, 0.1]], "_default", ["_round", -1]];
    if (isLocalized _tooltip) then {
        _tooltip = localize _tooltip;
    };
    private _cacheName = format ["lambs_%1_%2", _name, _text];
    _default = GVAR(ChooseDialogSettingsCache) getVariable [_cacheName, _default];

    // if no Default is Given we use the middle of the Range input
    if (isNil "_default") then {
        _default = linearConversion [0, 1, 0.5, _range select 0, _range select 1, true];
    };
    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);
    [_text, _tooltip] call _fnc_CreateLabel;
    private _slider = _display ctrlCreate ["ctrlXSliderH", -1, _globalGroup];
    _slider ctrlSetPosition [_basePositionX + PX(CONST_WIDTH/2), _basePositionY + PY(CONST_HEIGHT / 2), PX(CONST_WIDTH/2 - (CONST_SPACE_HEIGHT * __SLIDER_EDIT_SIZE__)), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];
    _slider ctrlSetTooltip _tooltip;
    _slider sliderSetRange _range;
    _slider sliderSetSpeed _speed;
    _slider sliderSetPosition _default;

    private _textField = _display ctrlCreate ["RscEdit", -1, _globalGroup];
    _textField ctrlSetPosition [_basePositionX + PX(CONST_WIDTH - CONST_SPACE_HEIGHT * (__SLIDER_EDIT_SIZE__ - 1)), _basePositionY + PY((CONST_HEIGHT / 2)), PX(CONST_SPACE_HEIGHT * (__SLIDER_EDIT_SIZE__ - 2)), PY(CONST_HEIGHT / CONST_ELEMENTDIVIDER)];

    private _fnc_RoundValue = {
        params ["_newValue", "_control"];
        private _round = _control getVariable [QGVAR(Round), -1];
        if (_round != -1) then {
            private _roundTo = 10 ^ _round;
            _newValue = (round (_newValue * _roundTo))/_roundTo;
        };
        _newValue;
    };

    _slider setVariable [QGVAR(TextField), _textField];
    _textField setVariable [QGVAR(Slider), _slider];
    _textField setVariable [QGVAR(Round), _round];
    _slider setVariable [QGVAR(Round), _round];
    _textField setVariable [QFUNC(RoundValue), _fnc_RoundValue];
    _slider setVariable [QFUNC(RoundValue), _fnc_RoundValue];
    _textField ctrlSetText (str _default);

    _slider ctrlAddEventHandler ["SliderPosChanged", {
        params ["_slider", "_newValue"];
        private _textField = _slider getVariable [QGVAR(TextField), controlNull];
        _newValue = [_newValue, _slider] call (_slider getVariable [QFUNC(RoundValue), {_this select 0}]);
        _textField ctrlSetText (str _newValue);
        _textField ctrlCommit 0;
    }];

    _slider ctrlAddEventHandler ["KillFocus", {
        params ["_slider"];
        private _textField = _slider getVariable [QGVAR(TextField), controlNull];
        private _newValue = [sliderPosition _slider, _slider] call (_slider getVariable [QFUNC(RoundValue), {_this select 0}]);
        _slider sliderSetPosition _newValue;
        _textField ctrlSetText (str _newValue);
        _slider ctrlCommit 0;
        _textField ctrlCommit 0;
    }];

    _textField ctrlAddEventHandler ["KeyUp", {
        params ["_textField"];
        private _slider = _textField getVariable [QGVAR(Slider), controlNull];
        private _newValue = [parseNumber (ctrlText _textField), _slider] call (_textField getVariable [QFUNC(RoundValue), {_this select 0}]);
        _slider sliderSetPosition _newValue;
        _slider ctrlCommit 0;
    }];

    _textField ctrlAddEventHandler ["KillFocus", {
        params ["_textField"];
        private _slider = _textField getVariable [QGVAR(Slider), controlNull];
        private _newValue = [parseNumber (ctrlText _textField), _slider] call (_textField getVariable [QFUNC(RoundValue), {_this select 0}]);
        _slider sliderSetPosition _newValue;
        _slider ctrlCommit 0;
    }];

    _textField setVariable [QGVAR(CacheName), _cacheName];
    _slider ctrlCommit 0;
    _textField ctrlCommit 0;
    _textField;
    #undef __SLIDER_EDIT_SIZE__
};

private _fnc_AddSideSelector = {
    params ["_text", "", "_tooltip", "_sides", "_default"];
    _basePositionY = _basePositionY + PY(CONST_HEIGHT + CONST_SPACE_HEIGHT);

    private _cacheName = format ["lambs_%1_%2", _name, _text];
    _default = GVAR(ChooseDialogSettingsCache) getVariable [_cacheName, _default];

    [_text, _tooltip] call _fnc_CreateLabel;

    private _fnc_CreateButton = {
        params ["_tooltip", "_side", "_position"];
        private _button = _display ctrlCreate ["RscActivePictureKeepAspect", -1, _globalGroup];
        _button ctrlSetPosition _position;
        private _index = [west, east, independent, civilian, sideEmpty, sideLogic, sideUnknown] find _side;
        if (_tooltip == "") then {
            _tooltip = [_side] call BIS_fnc_sideName;
        };
        if (isLocalized _tooltip) then {
            _tooltip = localize _tooltip;
        };
        if (_index == -1) then {
            _index = 5; // if Side is not known use sideLogic Icon
        };
        _button ctrlSetText (["a3\3den\Data\Displays\Display3DEN\PanelRight\side_west_ca.paa", "a3\3den\Data\Displays\Display3DEN\PanelRight\side_east_ca.paa", "a3\3den\Data\Displays\Display3DEN\PanelRight\side_guer_ca.paa", "a3\3den\Data\Displays\Display3DEN\PanelRight\side_civ_ca.paa", "a3\3den\Data\Displays\Display3DEN\PanelRight\side_empty_ca.paa", "a3\3den\Data\Displays\Display3DEN\PanelRight\side_custom_ca.paa", "a3\3den\Data\Displays\Display3DEN\PanelRight\submode_logic_logic_ca.paa"] select _index);
        _button ctrlSetTooltip _tooltip;
        _button ctrlAddEventHandler ["MouseButtonUp", {
            params ["_ctrl"];
            private _buttons = _ctrl getVariable [QGVAR(Controls), controlNull];
            (_buttons select 0) setVariable [QGVAR(SelectedSide), _ctrl getVariable [QGVAR(Side), sideUnknown]];
            {
                _x ctrlSetTextColor [1, 1, 1, 0.25];
            } forEach _buttons;
            _ctrl ctrlSetTextColor [1, 1, 1, 1];
            _ctrl ctrlCommit 0;
        }];
        _button setVariable [QGVAR(Side), _side];
        _button ctrlSetTextColor [1, 1, 1, 0.25];
        _button ctrlCommit 0;
        _button;
    };

    _sides = _sides arrayIntersect _sides;
    if (isNil "_default" || { !(_default in _sides) }) then {
        _default = _sides select 0;
    };

    private _buttons = [];
    private _count = count _sides;
    private _margin = PX((CONST_WIDTH/2 - _count*(CONST_HEIGHT+CONST_SPACE_HEIGHT) - CONST_SPACE_HEIGHT)/2);
    private _xoffset = PX(CONST_HEIGHT+CONST_SPACE_HEIGHT);
    private _xpos = _basePositionX + PX(CONST_WIDTH/2) + _margin;
    {
        _x params ["_side", ["_tooltip", "", [""]]];
        private _b = [_tooltip, _side, [_xpos, _basePositionY, PX(CONST_HEIGHT), PY(CONST_HEIGHT)]] call _fnc_CreateButton;
        _xpos = _xpos + _xoffset;
        _buttons pushBack _b;
        if (_default == _side) then {
            (_buttons select 0) setVariable [QGVAR(SelectedSide), _side];
            _b ctrlSetTextColor [1, 1, 1, 1];
        };
    } forEach _sides;

    {
        _x setVariable [QGVAR(Controls), _buttons];
        _x setVariable [QGVAR(CacheName), _cacheName];
    } forEach _buttons;
    _buttons select 0;
};

private _controls = [];
{
    private _type = toUpperANSI (_x select 1);
    switch (_type) do {
        case ("BOOLEAN");
        case ("BOOL"): {
            _controls pushBack [(_x call _fnc_AddBoolean), _type];
        };
        case ("LISTBOX");
        case ("LIST");
        case ("DROPDOWN"): {
            _controls pushBack [(_x call _fnc_AddDropDown), _type];
        };
        case ("SLIDER"): {
            _controls pushBack [(_x call _fnc_AddSlider), _type];
        };
        case ("NUMBER");
        case ("INT");
        case ("INTEGER");
        case ("TEXT");
        case ("EDIT"): {
            _controls pushBack [(_x call _fnc_AddTextField), _type];
        };
        case ("DESCRIPTION"): {
            _x call _fnc_DescriptionField; // This Type does not generate any Data and will not be enterted into the return data
        };
        case ("SIDE"): {
            _controls pushBack [(_x call _fnc_AddSideSelector), _type];
        };
        default {
            _controls pushBack [(_x call _fnc_AddTextField), _type];
            hint format ["%1 type unknown %2", _type, _x];
            // TYPE NOT FOUND
        };
    };
} forEach _data;

_basePositionY = _basePositionY + PY(CONST_HEIGHT + (CONST_SPACE_HEIGHT*2));

private _cancelButton = _display ctrlCreate ["RscButton", -1, _globalGroup];
_cancelButton ctrlSetText (localize "STR_DISP_CANCEL");

_cancelButton ctrlSetPosition [_basePositionX, _basePositionY, PX(CONST_WIDTH / 2)- PX(CONST_SPACE_HEIGHT/2), PY(CONST_HEIGHT / 2)];

_cancelButton ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _display = ctrlParent _ctrl;
    (_display getVariable [QGVAR(Params), []]) call (_display getVariable [QGVAR(OnAbort), {}]);
    closeDialog 2;
}];
_cancelButton ctrlCommit 0;

private _okButton = _display ctrlCreate ["RscButton", -1, _globalGroup];
_okButton ctrlSetText (localize "STR_DISP_OK");
_okButton ctrlSetPosition [_basePositionX + PX(CONST_WIDTH / 2) + PX(CONST_SPACE_HEIGHT/2), _basePositionY, PX(CONST_WIDTH / 2) - PX(CONST_SPACE_HEIGHT/2), PY(CONST_HEIGHT / 2)];

_okButton ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _display = ctrlParent _ctrl;

    private _data = _display call FUNC(parseData);
    [_data, (_display getVariable [QGVAR(Params), []])] call (_display getVariable [QGVAR(OnComplete), {}]);
    closeDialog 1;
}];

_display setVariable [QGVAR(OnComplete), _OnComplete];
_display setVariable [QGVAR(ControlData), _controls];
_display setVariable [QGVAR(OnAbort), _OnAbort];
_display setVariable [QGVAR(OnUnload), _OnUnload];
_display setVariable [QGVAR(Params), _params];

_okButton ctrlCommit 0;
