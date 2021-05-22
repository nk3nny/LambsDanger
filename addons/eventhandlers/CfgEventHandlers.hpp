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
            Explosion = QUOTE(_this call FUNC(explosionEH));
        };
    };
};

class Extended_Suppressed_Eventhandlers {
    class CAManBase {
        class LAMBS_CAManBase_suppressed {
            Suppressed = QUOTE(_this call FUNC(suppressedEH));
        };
    };
};
