class ctrlMenuStrip;
class Display3DEN {
    class Controls {
        class MenuStrip: ctrlMenuStrip {
            class Items {
                class Tools {
                    items[] += {
                        QGVAR(AIProfileEditor)
                    };
                };
                class GVAR(AIProfileEditor) {
                    text = CSTRING(OpenAIProfileEditor);
                    picture = "\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa";
                    action = QUOTE(call FUNC(profileEditor));
                    shortcuts[] = {};
                    opensNewWindow = 1;
                };
            };
        };
    };
};
