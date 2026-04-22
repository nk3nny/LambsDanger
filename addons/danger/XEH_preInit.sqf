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
    GVAR(dangerUntil) = 3;
};

// EH handling reinforcement and combat mode
[QEGVAR(main,OnInformationShared), {
    params [["_unit", objNull], "", ["_target", objNull], ["_groups", []]];
    private _sideGroups = _groups select {(side _x) isEqualTo (side _unit)};

    // reinforce
    if (!isNull _target) then {
        private _reinforceGroups = _sideGroups select {
            private _leader = leader _x;
            local _leader
            && {_x getVariable [QGVAR(enableGroupReinforce), false]}
            && {(_x getVariable [QGVAR(enableGroupReinforceTime), -1]) < time}
        };

        private _maxGroups = GVAR(maxReinforcementGroups);
        if (
            _maxGroups > 0
            && {(count _reinforceGroups) > _maxGroups}
        ) then {
            _reinforceGroups = [_reinforceGroups, [], {leader _x distance2D _unit}, "ASCEND"] call BIS_fnc_sortBy;
            _reinforceGroups resize _maxGroups;
        };

        // get pos of enemy if available
        private _pos = [getPosASL _unit, (_unit targetKnowledge _target) select 6] select (_unit knowsAbout _target > 1.5);

        // check for zero pos
        if (_pos isEqualTo [0, 0, 0]) then {_pos = getPosASL _unit;};

        // find free space
        private _adjustPos = _pos findEmptyPosition [5, 35, "Land_BagBunker_Large_F"];
        if (_adjustPos isNotEqualTo []) then {_pos = _adjustPos;};

        {
            [leader _x, _pos] call FUNC(tacticsReinforce);
        } forEach _reinforceGroups;
    };

    {
        private _leader = leader _x;
        if (local _leader) then {
            // reorientate group
            if (
                !(_leader getVariable [QGVAR(disableAI), false])
                && {(behaviour _leader) isNotEqualTo "COMBAT"}
            ) then {
                //[units _x, _target, [_leader, 40, true, true] call EFUNC(main,findBuildings), "information"] call EFUNC(main,doGroupHide);
                _x setFormDir (_leader getDir _unit);
            };
        };
    } forEach _sideGroups;
}] call CBA_fnc_addEventHandler;

ADDON = true;
