#include "script_component.hpp"
/*
 * Author: nkenny
 * Callouts on throwing (and receiving grenades)
 *
 * Arguments:
 * 0: unit that reacts <OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob] call lambs_eventhandlers_fnc_firedEH;
 *
 * Public: No
*/

// init
params ["_unit", "_weapon", "_muzzle", "", "", "_projectile"];

// Standing or recent explosions ignored
if (
    !GVAR(GrenadeEventHandlerEnabled)
    || !(local _unit)
    || _unit getVariable [QEGVAR(danger,disableAI), false]
) exitWith {false};

// is it a grenade?
if (_weapon isEqualTo "Throw" && {"renade" in _muzzle}) then {

    // self message!
    if (RND(0.4) && !isPlayer _unit) then {
        [_unit, ["Combat", "Stealth"] select (behaviour _unit isEqualTo "STEALTH"), "grenadeout"] call EFUNC(main,doCallout);
    };

    // enemy exists and is within 5-8m of projectile
    [{
        params [["_projectile", objNull], ["_side", civilian]];
        private _enemies = ((ASLToAGL (getPosASL _projectile)) nearEntities ["CAManBase", 5 + random 3]) select {(side _x) isNotEqualTo _side && !isPlayer _x};
        if (count_enemies > 4) then {_enemies resize 4;};
        {
            if (RND(0.2)) then {[QGVAR(incomingGrenade), _x, _x] call CBA_fnc_targetEvent;};
        } forEach _enemies;
    }, [_projectile, side group _unit], 0.5 + random 1] call CBA_fnc_waitAndExecute;

};

// end
true
