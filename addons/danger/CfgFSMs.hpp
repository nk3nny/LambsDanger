class CfgFSMs {
    class Formation {
        class States {
            // drop to ground ~ do nothing instead! <-- TOP ONE IS THE ONE WE'VE GENERALLY USED!! - nkenny
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
                    parameters[] = {32, 8}; // 30,6 works, also 26,8 -- tested 36,12 for longer bounds -- 26, 8 v2.0 -- back to 30,6 Lets go crazy! -- nkenny
                    thresholds[] = {};
                };
            };
        };
    };
};