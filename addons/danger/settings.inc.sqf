private _curCat = ELSTRING(main,Settings_MainCat);
// Toggle advanced danger.fsm features on player group
[
    QGVAR(disableAIPlayerGroup),
    "CHECKBOX",
    [LSTRING(Settings_DisableDangerFSM), LSTRING(Settings_DisableDangerFSM_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    0         // players may configure their own preferences
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


_curCat = LSTRING(Settings_GeneralCat);

// Range at which units consider themselves in CQB
[
    QGVAR(cqbRange),
    "SLIDER",
    [LSTRING(Settings_CQBRange), LSTRING(Settings_CQBRange_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [20, 150, 60, 0],
    1
] call CBA_fnc_addSetting;


// Chance of panic expressed as percentage
[
    QGVAR(panicChance),
    "SLIDER",
    [LSTRING(Settings_PanicChance), LSTRING(Settings_PanicChance_ToolTip)],
    [COMPONENT_NAME, _curCat],
    [0, 1, 0.1, 2, true],
    1
] call CBA_fnc_addSetting;

addMissionEventHandler ["GroupCreated", {
    params ["_group"];
    [
        {
            if (count (units _this) > 0) then {
                if (GVAR(autoAddDynamicReinforcement)) then {_this setVariable [QGVAR(enableGroupReinforce), true, true];};
                if !(GVAR(disableAttackOverride)) then {_this enableAttack false;};
                if (GVAR(disableFleeingOverride)) then {_this allowFleeing 0;};
            };
        },
        _group,
        3
    ] call CBA_fnc_waitAndExecute;
}];

// auto disable enableAttack on groups
[
    QGVAR(disableAttackOverride),
    "CHECKBOX",
    [LSTRING(Settings_AttackOverride), LSTRING(Settings_AttackOverride_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    false, {
        params ["_value"];
        if (_value) exitWith {};
        if (!_value && time > 0) then {
            {_x enableAttack false;} forEach (allGroups select {local (leader _x)});
        };
    }
] call CBA_fnc_addSetting;

// auto disable allowFleeing on groups
[
    QGVAR(disableFleeingOverride),
    "CHECKBOX",
    [LSTRING(Settings_FleeingOverride), LSTRING(Settings_FleeingOverride_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    false, {
        params ["_value"];
        if (_value) exitWith {};
        if (!_value && time > 0) then {
            {_x allowFleeing 0;} forEach (allGroups select {local (leader _x)});
        };
    }
] call CBA_fnc_addSetting;

// auto add dynamic reinforcement
[
    QGVAR(autoAddDynamicReinforcement),
    "CHECKBOX",
    [LSTRING(Settings_UniversalDynamicReinforcement), LSTRING(Settings_UniversalDynamicReinforcement_ToolTip)],
    [COMPONENT_NAME, _curCat],
    false,
    false, {
        params ["_value"];
        if (!_value) exitWith {};
        if (_value) then {
            {_x setVariable [QGVAR(enableGroupReinforce), true, true];} forEach (allGroups select {local (leader _x)});
        };
    }
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
