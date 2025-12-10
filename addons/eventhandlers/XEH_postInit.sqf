#include "script_component.hpp"


// placed here because I'm not sure where best practice to place it would be! ~nkenny
["ModuleCurator_F", "init", {

    (_this select 0) addEventHandler ["CuratorWaypointPlaced", {call FUNC(curatorWaypointPLacedEH)}];
}, true, [], true] call CBA_fnc_addClassEventHandler;
