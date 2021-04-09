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

class LAMBS_CfgAIProfilesValueDescriptions {
    #ifdef ISDEV
    class allowDemoNumberAsBool {
        name = "Demo allowDemoNumberAsBool";
        description = "Description of allowDemoNumberAsBool";
    };
    class allowDemoRandom {
        name = "Demo Setting allowDemoRandom";
        description = "Description of allowDemoRandom";
    };
    class allowDemoBool {
        name = "Demo allowDemoBool";
        description = "Description of allowDemoBool";
    };
    class allowDemoBool2 {
        name = "Demo allowDemoBool2";
        description = "Description of allowDemoBool2";
    };
    class allowDemoCodeBool {
        name = "Demo allowDemoCodeBool";
        description = "Description of allowDemoCodeBool";
    };
    class allowDemoCodeNumber {
        name = "Demo allowDemoCodeNumber";
        description = "Description of allowDemoCodeNumber";
    };
    #endif
};
