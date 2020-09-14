#include "script_component.hpp"
/*
 * Author: nkenny
 * Group leadership handler -- leads to profiles, assessments, contact state and other responses
 *
 * Arguments:
 * 0: group leader <OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob] call lambs_danger_fnc_tactics;
 *
 * Public: No
*/
params [["_unit", objNull, [objNull]]];

// CQB mode ~ disabled awaiting polish ~ nkenny
//if (formation _unit in GVAR(cqb_formations)) exitWith {
//    _unit call FUNC(tacticsCQB);
//};

// check if group AI disabled
if ((group _unit) getVariable [QGVAR(disableGroupAI), false]) exitWith {false};

// Initated contact?
private _contactState = group _unit getVariable [QGVAR(contact), 0];
if (_contactState < time) exitWith {_unit call FUNC(tacticsContact)};

// ai profiles ~ here is where AI profiles will be extrapolated - nkenny
if (_unit call FUNC(tacticsProfiles)) exitWith {true};

// Leader assessment
if (!isplayer leader _unit) then {_unit call FUNC(tacticsAssess);};

// end
true