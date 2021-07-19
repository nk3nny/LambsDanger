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
    private _value = switch (_type) do {
        case ("BOOLEAN");
        case ("BOOL"): {
            cbChecked _ctrl;
        };
        case ("NUMBER"): {
            parseNumber (ctrlText _ctrl);
        };
        case ("SLIDER"): {
            [parseNumber (ctrlText _ctrl), _ctrl] call (_ctrl getVariable [QFUNC(RoundValue), {_this select 0}]);
        };
        case ("INT");
        case ("INTEGER"): {
            round (parseNumber (ctrlText _ctrl));
        };
        case ("LIST");
        case ("LISTBOX");
        case ("DROPDOWN"): {
            lbCurSel _ctrl;
        };
        case ("TEXT");
        case ("EDIT"): {
            ctrlText _ctrl;
        };
        case ("SIDE"): {
            _ctrl getVariable [QGVAR(SelectedSide), sideUnknown];
        };
        default {
            private _str = format ["%1 type unknown %2", _type, _x];
            hint _str;
            diag_log _str;
            ctrlText _ctrl;
        };
    };
    private _cacheName = _ctrl getOrDefault [QGVAR(CacheName), ""];
    GVAR(ChooseDialogSettingsCache) set [_cacheName, _value];
    _data pushback _value;
} forEach (_element getVariable [QGVAR(ControlData), []]);

_data;
