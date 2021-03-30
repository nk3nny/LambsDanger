/*
 * Author: mjc4wilton
 * Adds a custom handler to be called whenever the AI attempt to share information.
 * Code should return a BOOL where false allows information to be passed and true blocks it.
 * A single true will cause information to not be shared.
 *
 * Arguments:
 * 0: function <CODE>
 *
 * Arguments passed to function:
 * 0: unit sharing information <OBJECT>
 * 1: enemy target <OBJECT>
 * 2: range to share information, default 350 <NUMBER>
 * 3: override radio ranges, default false <BOOLEAN>
 *
 * Return Value:
 * None
 *
 * Example:
 * [{false}] call lambs_main_fnc_addShareInformationHandler;
 *
 * Public: No
*/

params [["_code", {true}, [{}]]];

GVAR(shareHandlers) pushBack _code;
