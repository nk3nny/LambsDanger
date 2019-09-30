#include "script_component.hpp"
// DEBUG : return marker color suitable to side
// version 1.01
// by nkenny

// init
params ["_unit"];

// return
if (side _unit isEqualTo EAST) exitWith {"colorEAST"};
if (side _unit isEqualTo WEST) exitWith {"colorWEST"};
if (side _unit isEqualTo CIVILIAN) exitWith {"ColorCIV"};
"colorIndependent"
