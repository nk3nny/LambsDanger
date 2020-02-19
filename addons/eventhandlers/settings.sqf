private _curCat = "Explosion";

[
    QGVAR(ExplosionEventHandlerEnabled),
    "CHECKBOX",
    ["Enable Explosion Eventhandler", "Toggle AI Reactions to nearby explosions"],
    [COMPONENT_NAME, _curCat],
    true,
    true         // players may configure their own preferences
] call CBA_fnc_addSetting;

[
    QGVAR(ExplosionReactionTime),
    "SLIDER",
    ["Explosion EH reset Time", "Configures explosions reset time."],
    [COMPONENT_NAME, _curCat],
    [0, 25, 9, 2],
    true         // players may configure their own preferences
] call CBA_fnc_addSetting;
