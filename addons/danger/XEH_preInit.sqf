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

// FSM setting ~ range to search for hide and cover
if (isNil QGVAR(searchForHide)) then {
    GVAR(searchForHide) = 4;
};

ADDON = true;
