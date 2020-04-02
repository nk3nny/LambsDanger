#include "script_component.hpp"
/*
 * Author: joko // Jonas
 *
 *
 * Arguments:
 *
 *
 * Return Value:
 *
 *
 * Example:
 *
 *
 * Public: No
*/
params ["_unit", "_animation", ["_priority", 0]];

// switchMove "" no longer works in dev 1.37
if (_animation == "") then {
    private _anim = toLower animationState _unit;

    // stance is broken for some animations.
    private _stance = stance _unit;

    if (_anim find "ppne" == 4) then {
        _stance = "PRONE";
    };

    if (_anim find "pknl" == 4) then {
        _stance = "CROUCH";
    };

    if (_anim find "perc" == 4) then {
        _stance = "STAND";
    };

    _anim = format ["AmovP%1M%2S%3W%4D%5",
        ["erc", "knl", "pne"] select (["STAND", "CROUCH", "PRONE"] find _stance) max 0,
        ["stp", "run"] select (vectorMagnitude velocity _unit > 1),
        [["ras", "low"] select weaponLowered _unit, "non"] select (currentWeapon _unit == ""),
        ["non", "rfl", "lnr", "pst", "bin"] select (["", primaryWeapon _unit, secondaryWeapon _unit, handgunWeapon _unit, binocular _unit] find currentWeapon _unit) max 0,
        ["non", _anim select [count _anim - 1, 1]] select (_anim select [count _anim - 2, 2] in ["df", "db", "dl", "dr"])
    ];

    _animation = ["", _anim] select isClass (configFile >> "CfgMovesMaleSdr" >> "States" >> _anim)
};

switch (_priority) do {
    case 0: {
        if (_unit == vehicle _unit) then {
            [_unit, _animation] remoteExec ["playMove", _unit];
        } else {
            // Execute on all machines. PlayMove and PlayMoveNow are bugged: They have local effects when executed on remote machines inside vehicles.
            [_unit, _animation] remoteExec ["playMove", 0];
        };
    };
    case 1: {
        if (_unit == vehicle _unit) then {
            [_unit, _animation] remoteExec ["playMove", _unit];
        } else {
            // Execute on all machines. PlayMove and PlayMoveNow are bugged: They have local effects when executed on remote machines inside vehicles.
            [_unit, _animation] remoteExec ["playMove", 0];
        };
    };
    case 2: {
        if (_unit == vehicle _unit) then {
            [_unit, _animation] remoteExec ["playMove", _unit];
        } else {
            // Execute on all machines. PlayMove and PlayMoveNow are bugged: They have local effects when executed on remote machines inside vehicles.
            [_unit, _animation] remoteExec ["playMove", 0];
        };

        // if animation doesn't respond, do switchMove
        [{
            params ["_unit", "_animation"]
            if (animationState _unit != _animation) then {
                // Execute on all machines. SwitchMove has local effects.
                [_unit, _animation] remoteExec ["switchMove", 0];
            };
        }, [_unit, _animation], 0.1] call CBA_fnc_waitAndExecute;

    };
};
