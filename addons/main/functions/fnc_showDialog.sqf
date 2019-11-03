#include "script_component.hpp"
#include "\a3\ui_f\hpp\definedikcodes.inc"
params ["_name", "_data", "_OnComplete", "_OnAbort", "_OnUnload"];

private _display = (findDisplay 46) createDisplay "RscDisplayEmpty";

_display setVariable [QGVAR(OnAbort), _OnAbort];
_display setVariable [QGVAR(OnUnload), _OnUnload];
_display setVariable [QGVAR(OnComplete), _OnComplete];

_display displayAddEventHandler ["KeyDown",  {
    params ["_display", "_dikCode"];
    private _handled = false;
    if (_dikCode == DIK_ESCAPE) then {
        call (_display getVariable [QGVAR(OnClose), {}]); // Call On Close Handler
        _display closeDisplay 1;
        _handled = true;
    };
    _handled;
}];

_display displayAddEventHandler ["Unload",  {
    params ["_display"];
    call (_display getVariable [QGVAR(OnClose), {}]); // Call On Close Handler
}];

private _heigth = ((count _data) + 1) * (PY(5.5));

private _basePositionX = 0.5 - (PX(90) / 2);
private _basePositionY = 0.5 - (_heigth / 2);

private _globalGroup = _display ctrlCreate ["RscText", -1];
_globalGroup ctrlSetBackgroundColor BACKGROUND_RGB(0.8);
_globalGroup ctrlSetPosition [_basePositionX, 0.5 - (_heigth / 2), PX(90), _heigth];
_globalGroup ctrlCommit 0;

private _header = _display ctrlCreate ["RscText", -1, _globalGroup];
_header ctrlSetText _name;
_header ctrlSetFontHeight PY(5);
_header ctrlSetPosition [0.5 - (PX(90) / 2), _basePositionY, PX(90), PY(5)];
_header ctrlSetBackgroundColor COLOR_RGBA;
_header ctrlCommit 0;

private _fnc_CreateLabel = {
    params ["_text"];
    private _label = _display ctrlCreate ["RscText", -1, _globalGroup];
    _label ctrlSetPosition [_basePositionX + PY(0.5), _basePositionY, PX(45), PY(5)];
    _label ctrlSetFontHeight PY(2.5);
    _label ctrlSetText _text;
    _label ctrlCommit 0;
};

private _fnc_AddTextField = {
    params ["_text", "", "_tooltip", "_default"];
    _basePositionY = _basePositionY + PY(5.5);
    _text call _fnc_CreateLabel;

    private _textField = _display ctrlCreate ["RscEdit", -1, _globalGroup];
    _textField ctrlSetPosition [_basePositionX + PX(45), _basePositionY, PX(44.5), PY(5)];
    _textField ctrlSetText _default;
    _textField ctrlCommit 0;
};

private _fnc_AddBoolean = {
    params ["_text", "", "_tooltip", ["_default", false, [false]]];
    _basePositionY = _basePositionY + PY(5.5);
    _text call _fnc_CreateLabel;
    private _checkbox = _display ctrlCreate ["RscCheckBox", -1, _globalGroup];
    _checkbox ctrlSetPosition [_basePositionX + PX(84.5), _basePositionY, PX(5), PY(5)];
    _checkbox cbSetChecked _default;
    _checkbox ctrlCommit 0;
};

{
    switch (toUpper (_x select 1)) do {
        case ("BOOLEAN");
        case ("BOOL"): {
            _x call _fnc_AddBoolean;
        };
        default {
            _x call _fnc_AddTextField;
        };
    };
} forEach _data;
