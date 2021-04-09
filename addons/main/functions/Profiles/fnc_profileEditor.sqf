#include "script_component.hpp"
/*
 * Author: joko // Jonas
 *
 *
 * Arguments:
 *
 *
 * Return Value:
 *
 *
 * Example:
 *
 *
 * Public: No
*/
// [{ call Lambs_main_fnc_profileEditor; }, 2] call CBA_fnc_waitAndExecute;
#ifdef ISDEV
private _display = ([findDisplay 46, findDisplay 313] select is3DEN) createDisplay QGVAR(display);
#else
private _display = findDisplay 313 createDisplay QGVAR(display);
#endif

private _defaultProfile = configProperties [configFile >> "LAMBS_CfgAIProfiles" >> "default", "!isClass _x", true];
private _height = ((count _defaultProfile) + 1) * (PY(CONST_HEIGHT + CONST_SPACE_HEIGHT) * 2);

private _basePositionX = 0.5 - (PX(CONST_WIDTH) / 2);
private _basePositionY = 0.5 - (_height / 2);

private _globalGroup = _display ctrlCreate ["RscText", -1];
_globalGroup ctrlSetBackgroundColor BACKGROUND_RGB(0.8);
_globalGroup ctrlSetPosition [_basePositionX, 0.5 - (_height / 2), PX(CONST_WIDTH), _height];
_globalGroup ctrlCommit 0;

private _header = _display ctrlCreate ["RscText", -1, _globalGroup];
_header ctrlSetText "Profile: Default"; // TODO(joko): Add Profile Selector
_header ctrlSetFontHeight PY(CONST_HEIGHT);
_header ctrlSetPosition [0.5 - (PX(CONST_WIDTH / 2)), _basePositionY, PX(CONST_WIDTH), PY(5)];
_header ctrlSetBackgroundColor COLOR_RGBA;
_header ctrlCommit 0;

_display setVariable ["header", _header];

// TODO(joko): Code
// TODO(joko): Checkbox
// TODO(joko): Number
// TODO(joko): Clear
// TOOD(joko): New Profile
// TODO(joko): Duplicate Profile
// TODO(joko): Parsing
// TODO(joko): Saving
