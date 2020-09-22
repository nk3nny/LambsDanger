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
        7,      // DCHit
        4,      // DCEnemyNear
        3,      // DCExplosion
        1,      // DCDeadBodyGroup
        1,      // DCDeadBody
        2,      // DCScream
        6,      // DCCanFire
        5       // DCBulletClose
    ];
};

// FSM setting ~ minimum time for danger to last
if (isNil QGVAR(dangerUntil)) then {
    GVAR(dangerUntil) = 25;
};

// FSM setting ~ range to search for hide and cover
if (isNil QGVAR(searchForHide)) then {
    GVAR(searchForHide) = 4;
};

ADDON = true;
