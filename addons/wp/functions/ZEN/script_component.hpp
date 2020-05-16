#include "\z\lambs\addons\wp\script_component.hpp"

#define GET_GROUPS_CONTEXT(targets,groups,objects) targets append groups;\
{\
    if (_x isKindOf "CAManBase") then {\
        targets pushBackUnique (group _x);\
    } else {\
        targets append ((crew _x) apply {group _x});\
    };\
} forEach objects;\
targets = targets arrayIntersect targets
