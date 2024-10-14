private _curCat = ELSTRING(main,Settings_MainCat);
// Enable automatic artillery registration
DFUNC(ArtilleryScan) = {
    if (!GVAR(autoAddArtillery)) exitWith {
        GVAR(autoArtilleryRunning) = false;
    };
    {
        _x call FUNC(taskArtilleryRegister);
    } forEach (vehicles select {
        getNumber (configOf _x >> "artilleryScanner") > 0
        && {!(_x getVariable [QGVAR(autoAddArtilleryBlocked), false])}
    });
    GVAR(autoArtilleryRunning) = true;
    [{call FUNC(ArtilleryScan);}, [], 120] call CBA_fnc_waitAndExecute;
};

GVAR(autoArtilleryRunning) = false;

[
    QGVAR(autoAddArtillery),
    "CHECKBOX",
    [LSTRING(Settings_AutoRegisterArtillery_DisplayName), LSTRING(Settings_AutoRegisterArtillery_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    true, {
        params ["_value"];
        if (!_value) exitWith {};
        if (_value && !GVAR(autoArtilleryRunning)) then {
            call FUNC(ArtilleryScan);
        };
    }
] call CBA_fnc_addSetting;
