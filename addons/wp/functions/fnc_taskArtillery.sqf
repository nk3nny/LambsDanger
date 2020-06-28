#include "script_component.hpp"
/*
 * Author: nkenny
 * Requests artillery strike at location. Artillery strike has a cone-like 'beaten zone'
 *
 * Arguments:
 * 0: Side or Artillery unit <SIDE, OBJECT>
 * 1: Position targeted <ARRAY>
 * 2: Caller of strike <OBJECT>
 * 3: Rounds fired, default 3 - 7 <NUMBER>
 * 4: Dispersion accuracy, default 100 <NUMBER>
 * 5: Skip Check Rounds default false <BOOLEAN>
 *
 * Return Value:
 * none
 *
 * Example:
 * [side bob, getPos angryJoe, bob] spawn lambs_wp_fnc_taskArtillery;
 *
 * Public: Yes
*/
if ((_this select 0) isEqualType objNull) then {
    [QGVAR(FireArtillery), _this, (_this select 0)] call CBA_fnc_targetEvent;
} else {
    [QGVAR(RequestArtillery), _this] call CBA_fnc_serverEvent;
};

// end
true
