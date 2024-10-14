#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

// mod check
GVAR(Loaded_WP) = isClass (configFile >> "CfgPatches" >> "lambs_wp");

#include "settings.inc.sqf"

// FSM priorities ~ this could be made into CBA settings. But I kinda want to explore it a little first - nkenny
if (isNil QGVAR(fsmPriorities)) then {
    GVAR(fsmPriorities) = [
        2,      // DCEnemyDetected
        1,      // DCFire
        9,      // DCHit
        4,      // DCEnemyNear
        3,      // DCExplosion
        6,      // DCDeadBodyGroup
        3,      // DCDeadBody
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
[QEGVAR(main,OnInformationShared), {
    params [["_unit", objNull], "", ["_target", objNull], ["_groups", []]];
    {
        private _leader = leader _x;
        if (local _leader) then {
            // reinforce
            if (
                !isNull _target
                && {_x getVariable [QGVAR(enableGroupReinforce), false]}
                && {(_x getVariable [QGVAR(enableGroupReinforceTime), -1]) < time }
            ) then {
                [_leader, [getPosASL _unit, (_leader targetKnowledge _target) select 6] select (_leader knowsAbout _target > 1.5)] call FUNC(tacticsReinforce);
            };

            // reorientate group
            if (
                !(_leader getVariable [QGVAR(disableAI), false])
                && {(behaviour _leader) isNotEqualTo "COMBAT"}
            ) then {
                //[units _x, _target, [_leader, 40, true, true] call EFUNC(main,findBuildings), "information"] call EFUNC(main,doGroupHide);
                _x setFormDir (_leader getDir _unit);
            };
        };
    } forEach (_groups select {(side _x) isEqualTo (side _unit)});
}] call CBA_fnc_addEventHandler;

ADDON = true;
