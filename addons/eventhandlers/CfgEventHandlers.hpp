class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preStart));
    };
};
class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preInit));
    };
};
/* Not used
class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_postInit));
    };
};
*/
class Extended_Explosion_Eventhandlers {
    class CAManBase {
        class LAMBS_CAManBase_Explosion {
            Explosion = QUOTE(call FUNC(delayExplosionEH));
        };
    };
};
