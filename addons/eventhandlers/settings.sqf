private _curCat = "Explosion";

[
    QGVAR(ExplosionEventHandlerEnabled),
    "CHECKBOX",
    ["Enable Explosion Eventhandler", "Toggle Explosion Eventhander for AI Reactions to Explosions"],
    [COMPONENT_NAME, _curCat],
    true,
    true         // players may configure their own preferences
] call CBA_fnc_addSetting;

[
    QGVAR(ExplosionReactionTime),
    "SLIDER",
    ["Explosion Rection Time", "The Time the AI needs to reset before reacting to an Explosion Again"],
    [COMPONENT_NAME, _curCat],
    [0, 25, 9, 2],
    true         // players may configure their own preferences
] call CBA_fnc_addSetting;
