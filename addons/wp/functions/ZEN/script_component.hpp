#include "\z\lambs\addons\wp\script_component.hpp"

#define GET_GROUPS_CONTEXT(targets) params ["_groups", "_objects"]; \
targets append _groups;\
{\
    if (_x isKindOf "CAManBase") then {\
        targets pushBackUnique (group _x);\
    } else {\
        targets append ((crew _x) apply {group _x});\
    };\
} forEach _objects;\
targets = targets arrayIntersect targets
