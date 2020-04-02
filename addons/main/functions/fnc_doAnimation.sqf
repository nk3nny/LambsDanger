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
    _animation = toLower (animationState _unit);

    // stances are broken for some Animations
    private _stance = switch (_animation select [4, 4]) do {
        case ("ppne"): {"pne"};
        case ("pknl"): {"knl"};
        case ("perc"): {"erc"};
        default {
            ["erc", "knl", "pne"] select (["STAND", "CROUCH", "PRONE"] find stance _unit) max 0
        };
    };

    private _speed = ["stp", "run"] select ((vectorMagnitude (velocity _unit)) > 1);
    private _weaponAIndex = (["", primaryWeapon _unit, secondaryWeapon _unit, handgunWeapon _unit, binocular _unit] find (currentWeapon _unit)) max 0;
    private _weapon = ["non", "rfl", "lnr", "pst", "bin"] select _weaponAIndex;
    private _weaponPos = [["ras", "low"] select (weaponLowered _unit), "non"] select (currentWeapon _unit == "");
    private _prev = ["non", _animation select [(count _animation) - 1, 1]] select ((_animation select [(count _animation) - 2, 2]) in ["df", "db", "dl", "dr"]);

    _animation = format ["AmovP%1M%2S%3W%4D%5", _stance, _speed, _weaponPos, _weapon, _prev];

    _animation = ["", _animation] select isClass (configFile >> "CfgMovesMaleSdr" >> "States" >> _animation);
};

private _case = ["playMove", "playMoveNow"] select (_priority min 1);

// Execute on all machines. PlayMove and PlayMoveNow are bugged: They have no global effects when executed on remote machines inside vehicles.
if (isNull (objectParent _unit)) then {
    [_unit, _animation] remoteExec [_case, _unit];
} else {
    [_unit, _animation] remoteExec [_case, 0];
};

if (_priority >= 2 && {animationState _unit != _anim}) then {
    [{
        params ["_unit", "_animation"];
        if (animationState _unit != _animation) then {
            // Execute on all machines. SwitchMove has local effects.
            [_unit, _animation] remoteExec ["switchMove", 0];
        };
    }, [_unit, _animation], 0.1] call CBA_fnc_waitAndExecute;
};
