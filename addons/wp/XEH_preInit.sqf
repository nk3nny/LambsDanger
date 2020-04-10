#include "script_component.hpp"
ADDON = false;
#include "settings.sqf"
#include "XEH_PREP.hpp"
ADDON = true;

if (isServer) then {
    GVAR(SideArtilleryHash) = [[], []] call CBA_fnc_hashCreate;
    publicVariable QGVAR(SideArtilleryHash);
};

[QGVAR(RegisterArtillery), {
    private _artillery = [GVAR(SideArtilleryHash), side (_this select 0)] call CBA_fnc_hashGet;
    _artillery append _this;
    GVAR(SideArtilleryHash) = [GVAR(SideArtilleryHash), side (_this select 0), _artillery] call CBA_fnc_hashSet;
    publicVariable QGVAR(SideArtilleryHash);
}] call CBA_fnc_addEventhandler;

[QGVAR(RequestArtillery), {
    params ["_side", "_pos", "_caller", "_rounds", "_accuracy", "_skipCheckrounds"];
    private _artillery = [GVAR(SideArtilleryHash), _side] call CBA_fnc_hashGet;
    _artillery = _artillery select {
        canFire _x
        && {unitReady _x}
        && {_pos inRangeOfArtillery [[_x], getArtilleryAmmo [_x] select 0]};
    };
    _artillery = [_artillery, [], { _pos distance _x }, "ASCEND"] call BIS_fnc_sortBy;
    private _gun = _artillery deleteAt 0;
    GVAR(SideArtilleryHash) = [GVAR(SideArtilleryHash), _side, _artillery] call CBA_fnc_hashSet;
    publicVariable QGVAR(SideArtilleryHash);

    [QGVAR(FireArtillery), [_gun, _pos, _caller, _rounds, _accuracy, _skipCheckrounds]] call CBA_fnc_targetEvent
}] call CBA_fnc_addEventhandler;

[QGVAR(FireArtillery), {
    _this spawn FUNC(doArtillery);
}] call CBA_fnc_addEventhandler;
