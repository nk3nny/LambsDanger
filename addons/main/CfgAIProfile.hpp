class LAMBS_CfgAIProfiles {
    class Default {
        #ifdef ISDEV
        allowDemoNumberAsBool = 1;
        allowDemoRandom = 0.5;
        allowDemoBool = "true";
        allowDemoBool2 = "False";
        allowDemoCodeBool = "selectRandom [true, true, false, true, false, false]";
        allowDemoCodeNumber = "random 1";
        #endif
    };
};
