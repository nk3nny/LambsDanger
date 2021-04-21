class CfgVehicles {
    class All;
    class Static : All {
        coefInside = 1.5; // default: 2
        coefSpeedInside = 1.5; // default: 2
    };
    class Land;
    class Man : Land {
        crouchProbabilityCombat = 0.7;  // default: 0.4  ~ frankly not sure these have any effect...
        formationTime = 3; // default: 5
        formationX = 4.2; // default: 5
        brakeDistance = 1.5; // default: 5
    };
};
