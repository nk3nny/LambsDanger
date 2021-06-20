
class Lambs_Danger_DummyClass {

    #if __has_include("\userconfig\lambs_danger\range.hpp")
        #include "\userconfig\lambs_danger\range.hpp";
    #endif

    #ifndef LAMBS_RANGE_SENSITIVITY_MAN
        #define LAMBS_RANGE_SENSITIVITY_MAN 6
    #endif
};

class CfgVehicles {
    class Land;
    class Man : Land {
        sensitivity = LAMBS_RANGE_SENSITIVITY_MAN;
    };
};
