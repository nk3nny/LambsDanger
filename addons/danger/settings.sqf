private _curCat = LSTRING(Settings_MainCat);
// Toggle advanced danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroup),
    "CHECKBOX",
    [LSTRING(Settings_DisableDangerFSM), LSTRING(Settings_DisableDangerFSM_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0         // players may configure their own preferences
] call CBA_fnc_addSetting;

// Toggle advanced danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroupSuppression),
    "CHECKBOX",
    [LSTRING(Settings_DisableSuppressionPlayerGroup), LSTRING(Settings_DisableSuppressionPlayerGroup_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggle reaction state danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroupReaction),
    "CHECKBOX",
    [LSTRING(Settings_DisableReactPlayerGroup), LSTRING(Settings_DisableReactPlayerGroup_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles group manoevure phase initiated by AI squad leader
[
    QGVAR(disableAIAutonomousManoeuvres),
    "CHECKBOX",
    [LSTRING(Settings_DisableGroupManoevures), LSTRING(Settings_DisableGroupManoevures_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;


// Toggles the concealment AI for units not equipped to damage tanks and aircraft
[
    QGVAR(disableAIHideFromTanksAndAircraft),
    "CHECKBOX",
    [LSTRING(Settings_DisableUnitsHiding), LSTRING(Settings_DisableUnitsHiding_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;


// Toggles units dynamically deploying static weapons
[
    QGVAR(disableAIDeployStaticWeapons),
    "CHECKBOX",
    [LSTRING(Settings_DisableStaticDeployment), LSTRING(Settings_DisableStaticDeployment_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;


// Toggles units dynamically find and using static weapons
[
    QGVAR(disableAIFindStaticWeapons),
    "CHECKBOX",
    [LSTRING(Settings_DisableStaticFinding), LSTRING(Settings_DisableStaticFinding_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles units self-use of smoke grenades for cover
[
    QGVAR(disableAutonomousSmokeGrenades),
    "CHECKBOX",
    [LSTRING(Settings_DisableAutonomousSmokeGrenades), LSTRING(Settings_DisableAutonomousSmokeGrenades_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles units self-use of flares for illumation
[
    QGVAR(disableAutonomousFlares),
    "CHECKBOX",
    [LSTRING(Settings_DisableAutonomousFlares), LSTRING(Settings_DisableAutonomousFlares_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles AI Dodging
[
    QGVAR(disableAIDodge),
    "CHECKBOX",
    [LSTRING(Settings_DisableImmediateActions), LSTRING(Settings_DisableImmediateActions_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Toggles AI Enhanced fleeing
[
    QGVAR(disableAIFleeing),
    "CHECKBOX",
    [LSTRING(Settings_DisableEnhancedFleeing), LSTRING(Settings_DisableEnhancedFleeing_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

private _curCat = LSTRING(Settings_GeneralCat);

// Range at which units consider themselves in CQB
[
    QGVAR(cqbRange),
    "SLIDER",
    [LSTRING(Settings_CQBRange), LSTRING(Settings_CQBRange_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [20, 150, 60, 0],
    1
] call CBA_fnc_addSetting;

// Minimum range for suppression
[
    QGVAR(minSuppressionRange),
    "SLIDER",
    [LSTRING(Settings_MinSuppressDistance), LSTRING(Settings_MinSuppressDistance_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [1, 500, 25, 0],
    1
] call CBA_fnc_addSetting;

// 'Danger close' distance for suppression
[
    QGVAR(minFriendlySuppressionDistance),
    "SLIDER",
    [LSTRING(Settings_minFriendlySuppressionDistance), LSTRING(Settings_minFriendlySuppressionDistance_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [0, 50, 5, 0],
    1
] call CBA_fnc_addSetting;

// Chance of panic expressed as percentage
[
    QGVAR(panicChance),
    "SLIDER",
    [LSTRING(Settings_PanicChance), LSTRING(Settings_PanicChance_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [0, 1, 0.1, 0],
    1
] call CBA_fnc_addSetting;

// indoor movement while assessing chance as a percentage
[
    QGVAR(indoorMove),
    "SLIDER",
    [LSTRING(Settings_IndoorMove), LSTRING(Settings_IndoorMove_ToolTip)], // TODO(nkenny): Add Stringtable Entries!
    [COMPONENT_NAME, _curCat],
    [0, 1, 0.1, 0],
    1
] call CBA_fnc_addSetting;

private _curCat = LSTRING(Settings_ShareInformationCat);

// Toggle communication for all units
[
    QGVAR(radioDisabled),
    "CHECKBOX",
    [LSTRING(Settings_DisableInformationSharing), LSTRING(Settings_DisableInformationSharing_Tooltip)],
    [COMPONENT_NAME, _curCat],
    false,
    0
] call CBA_fnc_addSetting;

// Maximum Reveal Value -- Accuracy of shared information
[
    QGVAR(maxRevealValue),
    "SLIDER",
    [ LSTRING(Settings_maxRevealValue),  LSTRING(Settings_maxRevealValue_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [0, 4, 1, 2],
    1
] call CBA_fnc_addSetting;

// Combat share range
[
    QGVAR(combatShareRange),
    "SLIDER",
    [ LSTRING(Settings_combatShareRange),  LSTRING(Settings_combatShareRange_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [0, 1000, 200, 0],
    1
] call CBA_fnc_addSetting;

// Ranges at which groups share information
[
    QGVAR(radioShout),
    "SLIDER",
    [LSTRING(Settings_Shout), LSTRING(Settings_Shout_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [20, 200, 100, 0],
    1
] call CBA_fnc_addSetting;

// Base range of WEST side
[
    QGVAR(radioWest),
    "SLIDER",
    [LSTRING(Settings_BaseWest), LSTRING(Settings_BaseWest_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [20, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of EAST side
[
    QGVAR(radioEast),
    "SLIDER",
    [LSTRING(Settings_BaseEast), LSTRING(Settings_BaseEast_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [20, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of INDEPENDENT side
[
    QGVAR(radioGuer),
    "SLIDER",
    [LSTRING(Settings_BaseIndependent), LSTRING(Settings_BaseIndependent_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [20, 3000, 500, 0],
    1
] call CBA_fnc_addSetting;

// Base range of RadioBackpack
[
    QGVAR(radioBackpack),
    "SLIDER",
    [LSTRING(Settings_BackpackRadios), LSTRING(Settings_BackpackRadios_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [500, 6000, 2000, 0],
    1
] call CBA_fnc_addSetting;

/*
TEMPORARILY DISABLED FOR VERSION 2.5 RELEASE
WAITING BETTER OR OTHER SOLUTION
nkenny

// Configures CQC formations
_curCat = LSTRING(Settings_CQBFormationsCat);
GVAR(allPossibleFormations) = ["COLUMN", "STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "LINE", "FILE", "DIAMOND"];
GVAR(CQB_formations) = ["FILE", "DIAMOND"];     // Special CQB Formations )

DFUNC(UpdateCQBFormations) = {
    params ["_args", "_formation"];
    _args params ["_value"];
    if (_value) then {
        GVAR(CQB_formations) pushBackUnique _formation;
    } else {
        private _index = GVAR(CQB_formations) find _formation;
        if (_index != -1) then {
            GVAR(CQB_formations) deleteAt _index;
        };
    };
};

{
    private _code = compile format ["
        [_this, %1] call %2;
    ", str _x, QFUNC(UpdateCQBFormations)];
    [
        format [QGVAR(CQB_formations_%1), _x],
        "CHECKBOX",
        [_x, format ["%1 %2", _x, LLSTRING(Settings_CQBFormation)]],
        [COMPONENT_NAME, _curCat],
        _x in GVAR(CQB_formations),
        1, _code
    ] call CBA_fnc_addSetting;
} forEach GVAR(allPossibleFormations);

*/