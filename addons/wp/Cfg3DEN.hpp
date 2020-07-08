#define GRID_3DEN_W (pixelW * pixelGrid * 0.5)
#define GRID_3DEN_H (pixelH * pixelGrid * 0.5)

class ctrlToolbox;

class Cfg3DEN {
    class Attributes {
        class Default;
        class Title: Default {
            class Controls {
                class Title;
            };
        };
        class GVAR(Side): Title {
            attributeLoad = QUOTE((_this controlsGroupCtrl 100) lbSetCurSel (0 max _value min 2));
            attributeSave = QUOTE(lbCurSel (_this controlsGroupCtrl 100));
            class Controls: Controls {
                class Title: Title {};
                class Value: ctrlToolbox {
                    idc = 100;
                    x = QUOTE(48 * GRID_3DEN_W);
                    w = QUOTE(82 * GRID_3DEN_W);
                    h = QUOTE(5  * GRID_3DEN_H);
                    rows = 1;
                    columns = 3;
                    strings[] = { "$STR_A3_CfgGroups_West0", "$STR_A3_CfgGroups_East0", "$STR_A3_CfgGroups_Indep0" };
                };
            };
        };
        class GVAR(ExitConditions): Title {
            attributeLoad = QUOTE((_this controlsGroupCtrl 100) lbSetCurSel (0 max _value min 5));
            attributeSave = QUOTE(lbCurSel (_this controlsGroupCtrl 100));
            class Controls: Controls {
                class Title: Title {};
                class Value: ctrlToolbox {
                    idc = 100;
                    x = QUOTE(48 * GRID_3DEN_W);
                    w = QUOTE(82 * GRID_3DEN_W);
                    h = QUOTE(5  * GRID_3DEN_H);
                    rows = 1;
                    columns = 6;
                    strings[] = { CSTRING(Random), CSTRING(All), CSTRING(FiredNear), CSTRING(Fired), CSTRING(Hit), CSTRING(None) };
                };
            };
        };
    };
    class Object {
        class AttributeCategories {
            class EGVAR(Danger,attributes) {
                class Attributes {
                    class EGVAR(WP,Editor_IsArtillery) {
                        property = QEGVAR(WP,Editor_IsArtillery);
                        control = "Checkbox";
                        displayName = CSTRING(3DEN_Attributes_RegisterArtillery_DisplayName);
                        tooltip = CSTRING(3DEN_Attributes_RegisterArtillery_ToolTip);
                        expression = "if (_value) then {_this spawn {waitUntil {!isNil 'lambs_danger_Loaded_WP'};if (lambs_danger_Loaded_WP) then {[gunner _this] call lambs_wp_fnc_taskArtilleryRegister;};};};";
                        typeName = "BOOL";
                        condition = "objectVehicle";
                        defaultValue = "(false)";
                    };
                };
            };
        };
    };
};
