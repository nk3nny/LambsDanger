#include "script_component.hpp"
ADDON = false;
#include "settings.inc.sqf"
#include "XEH_PREP.hpp"

if (isServer) then {
    [QGVAR(RegisterArtillery), {
        {
            private _artillery = GVAR(SideArtilleryHash) getOrDefault [(side _x), []];
            _artillery pushBackUnique _x;
            GVAR(SideArtilleryHash) set [side _x, _artillery];
        } forEach _this;

        publicVariable QGVAR(SideArtilleryHash);
    }] call CBA_fnc_addEventhandler;

    [QGVAR(RequestArtillery), {
        params [["_side", sideUnknown], ["_pos", [0, 0, 0]], ["_caller", objNull], ["_rounds", floor (3 + random 4)], ["_accuracy", 75], ["_skipCheckrounds", false]];
        private _artillery = GVAR(SideArtilleryHash) getOrDefault [_side, []];
        private _artillerySelected = _artillery select {
            canFire _x
            && {unitReady _x}
            && {simulationEnabled _x}
            && {_pos inRangeOfArtillery [[_x], getArtilleryAmmo [_x] param [0, ""]]};
        };
        if (_artillerySelected isEqualTo []) exitWith {};
        _artillerySelected = [_artillerySelected, [], { _pos distance _x }, "ASCEND"] call BIS_fnc_sortBy;
        private _gun = _artillerySelected select 0;
        _artillery deleteAt (_artillery find _gun);

        GVAR(SideArtilleryHash) set [_side, _artillery select {!isNull _x}];
        publicVariable QGVAR(SideArtilleryHash);
        [QGVAR(FireArtillery), [_gun, _pos, _caller, _rounds, _accuracy, _skipCheckrounds], _gun] call CBA_fnc_targetEvent;
    }] call CBA_fnc_addEventhandler;

    GVAR(SideArtilleryHash) = createHashMap;
    publicVariable QGVAR(SideArtilleryHash);
};

[QGVAR(FireArtillery), {
    _this spawn FUNC(doArtillery);
}] call CBA_fnc_addEventhandler;

// Remote Events for Tasks
[QGVAR(taskAssault), {
    _this spawn FUNC(taskAssault);
}] call CBA_fnc_addEventhandler;

[QGVAR(taskCamp), {
    _this call FUNC(taskCamp);
}] call CBA_fnc_addEventhandler;

[QGVAR(taskCQB), {
    _this spawn FUNC(taskCQB);
}] call CBA_fnc_addEventhandler;

[QGVAR(taskCreep), {
    _this spawn FUNC(taskCreep);
}] call CBA_fnc_addEventhandler;

[QGVAR(taskGarrison), {
    _this call FUNC(taskGarrison);
}] call CBA_fnc_addEventhandler;

[QGVAR(taskHunt), {
    _this spawn FUNC(taskHunt);
}] call CBA_fnc_addEventhandler;

[QGVAR(taskPatrol), {
    _this call FUNC(taskPatrol);
}] call CBA_fnc_addEventhandler;

[QGVAR(taskReset), {
    _this call FUNC(taskReset);
}] call CBA_fnc_addEventhandler;

[QGVAR(taskRush), {
    _this spawn FUNC(taskRush);
}] call CBA_fnc_addEventhandler;

[QGVAR(taskCampReset), {
    params ["_unit"];
    {
        _x enableAI 'ANIM';
        _x enableAI 'PATH';
        [_x, _x getVariable [QGVAR(eventhandlers), []]] call EFUNC(main,removeEventhandlers);
        _x setVariable [QGVAR(eventhandlers), nil];
    } forEach (units _unit);
    [_unit, "", 2] call EFUNC(main,doAnimation);
    _unit setUnitPos "AUTO";
}] call CBA_fnc_addEventhandler;

ADDON = true;
