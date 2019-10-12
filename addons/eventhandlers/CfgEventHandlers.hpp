class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preStart));
    };
};
class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};
/* Not used
class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};
*/
class Extended_Explosion_Eventhandlers {
    class CAManBase {
        class LAMBS_CAManBase_Explosion {
            Explosion = "_this call lambs_eventhandlers_fnc_explosionEH;";  // can this be compiled as FUNC() even within quotes? -nk
        };
    };
};
