#include "script_component.hpp"
#include "\a3\ui_f\hpp\definedikcodes.inc"
params ["_name", "_data", "_OnComplete", "_OnAbort", "_OnUnload"];

private _display = (findDisplay 312) createDisplay "RscDisplayEmpty";

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

private _heigth = ((count _data) + 1) * (PY(5) + PY(0.5));

private _contentGroup = _display ctrlCreate ["RscText", -1];
_contentGroup ctrlSetBackgroundColor BACKGROUND_RGB(0.8);
_contentGroup ctrlSetPosition [0.5 - (PX(90) / 2), 0.5 - (_heigth / 2), PX(90), _heigth];
_contentGroup ctrlCommit 0;

private _header = _display ctrlCreate ["RscText", -1, _contentGroup];
_header ctrlSetText _name;
_header ctrlSetPosition [0, 0, 1, PY(5)];
_header ctrlSetBackgroundColor COLOR_RGBA;
_header ctrlCommit 0;

/*
private _fnc_AddTextField = {

};

private _fnc_AddBoolean = {

};

{
    switch (toUpper (_x select 2)) do {
        case ("BOOLEAN");
        case ("BOOL"): {
            _x call _fnc_AddBoolean;
        };
        default {
            _x call _fnc_AddTextField;
        };
    };
} forEach _data;
*/
