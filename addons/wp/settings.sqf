private _curCat = "Settings";
// Enable automatic artillery registration
DFUNC(ArtilleryScan) = {
    if (!GVAR(autoAddArtillery)) exitWith {
        GVAR(autoArtilleryRunning) = false;
    };
    {
        _x call FUNC(taskArtilleryRegister);
    } foreach (vehicles select { getNumber (configFile >> "CfgVehicles" >> (typeOf _x) >> "artilleryScanner") > 0 });
    GVAR(autoArtilleryRunning) = true;
    [{call FUNC(ArtilleryScan);}, [], 120] call CBA_fnc_waitAndExecute;
};

GVAR(autoArtilleryRunning) = false;

[
    QGVAR(autoAddArtillery),
    "CHECKBOX",
    ["Enable automatic artillery registration", "Automatically adds artillery already present in the mission to Side"],
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
