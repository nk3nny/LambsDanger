class CfgVehicles {
    class All;
    class Static : All {
        coefInside = 1.5; // default: 2
        coefSpeedInside = 1.5; // default: 2
    };
    class Land;
    class Man : Land {
        crouchProbabilityCombat = 0; // 0.4;
        crouchProbabilityEngage = 0; // 0.75;
        crouchProbabilityHiding = 0; // 0.8;
        formationTime = 3; // default: 5
        formationX = 4.2; // default: 5
        brakeDistance = 1.5; // default: 5
    };
};
