#include "script_component.hpp"
/*
 * Author: joko // Jonas
 * Parses Data from UI Elements from Show Dialog
 *
 * Arguments:
 * 0: Control or Display <Control/Display>
 *
 * Return Value:
 * <Array> with Parsed Data
 *
 * Example:
 * _display call lambs_main_fnc_parseData;
 *
 * Public: No
*/
params ["_element"];
private _data = [];
{
    _x params ["_ctrl", "_type"];
    private _d = nil;
    switch (_type) do {
        case ("BOOLEAN");
        case ("BOOL"): {
            _d = cbChecked _ctrl;
        };
        case ("SLIDER");
        case ("NUMBER"): {
            _d = parseNumber (ctrlText _ctrl);
        };
        case ("INT");
        case ("INTEGER"): {
            _d = round (parseNumber (ctrlText _ctrl));
        };
        case ("LIST");
        case ("LISTBOX");
        case ("DROPDOWN"): {
            _d = lbCurSel _ctrl;
        };
        case ("TEXT");
        case ("EDIT"): {
            _d = ctrlText _ctrl;
        };
        case ("SIDE"): {
            _d = _ctrl getVariable [QGVAR(SelectedSide), sideUnknown];
        };
        default {
            _d = ctrlText _ctrl;
            hint format ["%1 type unknown %2", _type, _x];
        };
    };
    private _cacheName = _ctrl getVariable [QGVAR(CacheName), ""];
    GVAR(ChooseDialogSettingsCache) setVariable [_cacheName, _d];
    _data pushback _d;
} forEach (_element getVariable [QGVAR(ControlData), []]);

_data;
