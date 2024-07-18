#include "\x\cba\addons\main\script_macros_common.hpp"

#define DFUNC(var1) TRIPLES(ADDON,fnc,var1)
#define RND(var) random 1 > var

#define AI_AMMO_USAGE_FLAG_LIGHT 1
#define AI_AMMO_USAGE_FLAG_MARKING 2
#define AI_AMMO_USAGE_FLAG_CONCEALMENT 4
#define AI_AMMO_USAGE_FLAG_COUNTERMEASURES 8
#define AI_AMMO_USAGE_FLAG_MINE 16
#define AI_AMMO_USAGE_FLAG_UNDERWATER 32
#define AI_AMMO_USAGE_FLAG_INFATRY 64
#define AI_AMMO_USAGE_FLAG_VEHICLE 128
#define AI_AMMO_USAGE_FLAG_AIR 256
#define AI_AMMO_USAGE_FLAG_ARMOUR 512

#define GET_CURATOR_GRP_UNDER_CURSOR call { \
    private _group = grpNull; \
    private _mouseOver = missionNamespace getVariable ["BIS_fnc_curatorObjectPlaced_mouseOver", [""]]; \
    if ((_mouseOver select 0) isEqualTo (typeName objNull)) then { _group = group (_mouseOver select 1); };\
    if ((_mouseOver select 0) isEqualTo (typeName grpNull)) then { _group = _mouseOver select 1; }; \
    _group; \
}

#define GET_CURATOR_UNIT_UNDER_CURSOR call { \
    private _unit = objNull; \
    private _mouseOver = missionNamespace getVariable ["BIS_fnc_curatorObjectPlaced_mouseOver", [""]]; \
    if ((_mouseOver select 0) isEqualTo (typeName objNull)) then { _unit = _mouseOver select 1; };\
    if ((_mouseOver select 0) isEqualTo (typeName grpNull)) then { _unit = leader (_mouseOver select 1); }; \
    _unit \
}

// #define DISABLE_COMPILE_CACHE

#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #define PREP(fncName) DFUNC(fncName) = compileScript [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)]
#else
    #undef PREP
    #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction
#endif

#ifdef SUBPREP
    #undef SUBPREP
#endif

#ifdef DISABLE_COMPILE_CACHE
    #define SUBPREP(sub,fncName) DFUNC(fncName) = compileScript [QPATHTOF(functions\sub\DOUBLES(fnc,fncName).sqf)]
#else
    #define SUBPREP(sub,fncName) [QPATHTOF(functions\sub\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction
#endif
