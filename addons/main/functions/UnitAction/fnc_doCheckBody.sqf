#include "script_component.hpp"
/*
 * Author: nkenny
 * Unit moves to check a body
 *
 * Arguments:
 * 0: unit doing the checking <OBJECT>
 * 1: position to check <ARRAY>
 * 2: Radius to check for bodies <NUMBER>, default 8 meters
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob, getpos angryJoe, 10] call lambs_main_fnc_doCheckBody;
 *
 * Public: No
*/
params ["_unit", ["_pos", []], ["_radius", 8]];

// check
if (_pos isEqualTo []) then {_pos = getPosASL _unit;};

// find body + rearm
private _weaponHolders = allDeadMen findIf { (_x distance2D _pos) < _radius };
if (_weaponHolders isEqualTo -1) exitWith {false};

// body
private _body = allDeadMen select _weaponHolders;

// execute
_unit setUnitPosWeak "MIDDLE";
_unit doMove (getPosATL _body);
_unit doWatch _body;
_unit setVariable [QEGVAR(danger,forceMove), true];
[
    {
        // condition
        params ["_unit", "_body"];
        (_unit distance _body < 0.8) || {!(_unit call FUNC(isAlive))}
    },
    {
        // on near body
        params ["_unit", "_body"];
        if (_unit call FUNC(isAlive)) then {
            [QGVAR(OnCheckBody), [_unit, group _unit, _body]] call FUNC(eventCallback);
            _unit action ["rearm", _body];

            // get backpack
            if ((backpack _unit) isEqualTo "" && {backpack _body isNotEqualTo ""}) then {
                private _items = backpackItems _body;
                private _backpack = backpack _body;
                removeBackpack _body;
                _unit addBackpack _backpack;
                {_unit addItemToBackpack _x} forEach _items;
            };

            // get launchers
            if (secondaryWeapon _unit isEqualTo "") then {
                private _weaponHolders = _body nearSupplies 3;
                private _weapons = _weaponHolders apply {getWeaponCargo _x};
                private _index = _weapons findIf {getNumber (configFile >> "CfgWeapons" >> ((_x select 0) select 0) >> "Type") isEqualTo 4};
                if (_index isNotEqualTo -1) then {
                    _unit action ["TakeWeapon", _weaponHolders select _index, ((_weapons select _index) select 0) select 0];
                };
            };

            _unit doFollow leader _unit;
            _unit setVariable [QEGVAR(danger,forceMove), nil];
        };
    },
    [_unit, _body], 8,
    {
        // on timeout
        params ["_unit"];
        if (_unit call FUNC(isAlive)) then {
            _unit doFollow leader _unit;
            _unit setVariable [QEGVAR(danger,forceMove), nil];
        };
    }
] call CBA_fnc_waitUntilAndExecute;

// set variable
_unit setVariable [QGVAR(currentTarget), _pos, GVAR(debug_functions)];
_unit setVariable [QGVAR(currentTask), "Checking bodies", GVAR(debug_functions)];

// end
true
