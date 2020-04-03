#include "script_component.hpp"
ADDON = false;
#include "settings.sqf"
#include "XEH_PREP.hpp"
ADDON = true;

if (isServer) then {
    GVAR(SideArtilleryHash) = [[], []] call CBA_fnc_hashCreate;
    publicVariable QGVAR(SideArtilleryHash);
};

[QGVAR(RegisterArillery), {
    params ["_gun"];
    private _artillery = [GVAR(SideArtilleryHash), side _gun] call CBA_fnc_hashGet;
    _artillery pushBackUnique _gun;
    GVAR(SideArtilleryHash) = [GVAR(SideArtilleryHash), side _gun, _artillery] call CBA_fnc_hashSet;
    publicVariable QGVAR(SideArtilleryHash);
}] call CBA_fnc_addEventhandler;

[QGVAR(RequestArillery), {
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

    [QGVAR(FireArillery), [_gun, _pos, _caller, _rounds, _accuracy, _skipCheckrounds]] call CBA_fnc_targetEvent
}] call CBA_fnc_addEventhandler;

[QGVAR(FireArillery), {
    _this spawn FUNC(doArtillery);
}] call CBA_fnc_addEventhandler;
