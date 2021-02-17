#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

// mod check
GVAR(Loaded_WP) = isClass (configfile >> "CfgPatches" >> "lambs_wp");

#include "settings.sqf"

// FSM priorities ~ this could be made into CBA settings. But I kinda want to explore it a little first - nkenny
if (isNil QGVAR(fsmPriorities)) then {
    GVAR(fsmPriorities) = [
        3,      // DCEnemyDetected
        1,      // DCFire
        9,      // DCHit
        4,      // DCEnemyNear
        3,      // DCExplosion
        6,      // DCDeadBodyGroup
        2,      // DCDeadBody
        5,      // DCScream
        8,      // DCCanFire
        7,      // DCBulletClose
        0       // LAMBS Assess
    ];
};

// FSM setting ~ minimum time for danger to last
if (isNil QGVAR(dangerUntil)) then {
    GVAR(dangerUntil) = 4;
};

// EH handling reinforcement and combat mode
[
    QEGVAR(main,OnInformationShared), {
        params [["_unit", objNull], "", ["_target", objNull], ["_groups", []]];

        _groups = _groups select {local leader _x};
        {
            private _leader = leader _x;

            // reinforce
            if (!isNull _target && { _x getVariable [QGVAR(enableGroupReinforce), false] } && { (_x getVariable [QGVAR(enableGroupReinforceTime), -1]) < time }) then {
                [_leader, [getPosASL _unit, (_leader targetKnowledge _target) select 6] select (_leader knowsAbout _target > 1.5)] call FUNC(tacticsReinforce);
            };

            // set combatMode
            if !(_leader distance2D _unit > (EGVAR(main,combatShareRange)) && {_leader getVariable [QGVAR(disableAI), false]}) then {
                _x setBehaviour "COMBAT";
                _x setFormDir (_leader getDir _unit);
            };
        } forEach _groups;
}] call CBA_fnc_addEventHandler;

ADDON = true;
