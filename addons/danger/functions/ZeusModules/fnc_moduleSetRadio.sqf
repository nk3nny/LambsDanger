#include "script_component.hpp"

params ["_logic", "", "_activated"];

if (_activated && local _logic) then {

    //--- Get unit under cursor
    private _unit = objNull;
    private _mouseOver = missionNamespace getVariable ["BIS_fnc_curatorObjectPlaced_mouseOver", [""]];
    if ((_mouseOver select 0) isEqualTo (typeName objNull)) then { _unit = _mouseOver select 1; };

    //--- Check if the unit is suitable
    private _error = "";
    if (isNull _unit) then {
        _error = "No Unit Seleted";
    };
    if (isPlayer _unit) then {
        _error = "Players are not Valid Selections";
    };
    if (_error == "") then {
        ["Configure Long-range Radio",
            [
                ["Toggle boosted communication range on unit", "BOOLEAN", "Unit with radio toggled have boosted communications range when sharing information\nThis effect is also achieved by equipping the unit with a Vanilla Radio Backpack or TFAR-mod enabled radio.", _unit getVariable [QGVAR(dangerRadio), false]]
            ], {
                params ["_data", "_args"];
                _args params ["_unit", "_logic"];
                _data params ["_hasRadio"];
                _unit setVariable [QGVAR(dangerRadio), _hasRadio, true];
                deleteVehicle _logic;
            }, {
                params ["", "_logic"];
                deleteVehicle _logic;
            }, {
                params ["", "_logic"];
                deleteVehicle _logic;
            }, [_unit, _logic]
        ] call EFUNC(main,showDialog);
    } else {
        [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
        deleteVehicle _logic;
    };
};
