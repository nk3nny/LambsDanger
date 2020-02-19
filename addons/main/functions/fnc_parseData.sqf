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
} forEach (_element getVariable [QGVAR(ControlData), []]);

_data;
