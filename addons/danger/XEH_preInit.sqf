#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

// mod check
GVAR(Loaded_WP) = isClass (configfile >> "CfgPatches" >> "lambs_wp");

#include "settings.sqf"

// FSM priorities ~ this could be made into CBA settings. But I kinda want to explore it a little first - nkenny
GVAR(fsmPriorities) = [
    3,      // DCEnemyDetected
    1,      // DCFire
    6,      // DCHit
    5,      // DCEnemyNear
    3,      // DCExplosion
    1,      // DCDeadBodyGroup
    1,      // DCDeadBody
    2,      // DCScream
    4,      // DCCanFire
    3       // DCBulletClose
];

ADDON = true;
