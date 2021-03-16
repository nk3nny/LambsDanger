private _curCat = LSTRING(Settings_Cat);

[
    QGVAR(ExplosionEventHandlerEnabled),
    "CHECKBOX",
    [LSTRING(Settings_EnabledExplosionEH_DisplayName), LSTRING(Settings_EnabledExplosionEH_ToolTip)],
    [COMPONENT_NAME, _curCat],
    true,
    true         // players may configure their own preferences
] call CBA_fnc_addSetting;

[
    QGVAR(ExplosionReactionTime),
    "SLIDER",
    [LSTRING(Settings_ExplosionResetTime_DisplayName), LSTRING(Settings_ExplosionResetTime_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [0, 25, 9, 2],
    true         // players may configure their own preferences
] call CBA_fnc_addSetting;
