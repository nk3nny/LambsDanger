class CfgFSMs {
    class Formation {
        class States {
            // drop to ground ~ do nothing instead!
            class Drop_to_ground {
                class Init {
                    function = "nothing";
                    parameters[] = {};
                    thresholds[] = {};
                };
            };
            // drop to ground in cover
            /*
            class Drop_to_ground_1 {
                class Init {
                    function = "nothing";
                    parameters[] = {};
                    thresholds[] = {};
                };
            };*/
            class Search_path__Covering {
                class Init {
                    function = "searchPath";
                    parameters[] = {36,12};   // 30,6 works well 26,8 -- current Lets go crazy!
                    thresholds[] = {};
                };
            };
        };
    };
};
