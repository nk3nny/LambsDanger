#include "script_component.hpp"
/*
 * Author: jokoho482, nkenny
 * Resets all unit orders
 *
 * Arguments:
 * 0: Unit being reset <OBJECT> or <GROUP>
 *
 * Return Value:
 * none
 *
 * Example:
 * TODO
 *
 * Public: No
*/

// TODO @ joko
/*

    1. Module does not need a dialogue
    2. Unit should be called 'Unit task Reset'  <-- this puts it at the bottom of alphabetic list
    3. Unit returns 'Unit orders reset' as Zeus notification if successful
    4. done 

*/

params ["_logic", "", "_activated"];

if(local _logic && _activated) then {
    
    // grabs unit under cursor
    private _group = GET_CURATOR_UNIT_UNDER_CURSOR;
    
    //--- Check if the unit is suitable
    private _error = "";
    if (isNull _group) then {
        _error = "No Unit Seleted";
    };

    // resets unit
    if (_error isEqualTo "") then {
        if (_group isEqualType objNull) then { _group = group _group; };
        [objNull, format ["%1 reset", groupId _group]] call BIS_fnc_showCuratorFeedbackMessage;
        [_group] call FUNC(taskReset);
    
    // display error
    } else {
        [objNull, _error] call BIS_fnc_showCuratorFeedbackMessage;
    };

    // clean up
    deleteVehicle _logic;

};
true