#include "script_component.hpp"
/*
 * Author: nkenny
 * Group leader assesses situation and calls manoeuvres or support assets as necessary
 *
 * Arguments:
 * 0: group leader <OBJECT>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [bob] call lambs_danger_fnc_tacticsAssess;
 *
 * Public: No
*/
#define TACTICS_HIDE 0
#define TACTICS_FLANK 1
#define TACTICS_GARRISON 2
#define TACTICS_ASSAULT 3
#define TACTICS_SUPPRESS 4
#define TACTICS_ATTACK 5

params [["_unit", objNull, [objNull]]];

// check if group AI disabled
private _group = group _unit;
if (_group getVariable [QGVAR(disableGroupAI), false]) exitWith {false};

// set variable
_group setVariable [QGVAR(isExecutingTactic), true];
_group setVariable [QGVAR(contact), time + 600];

// set current task
_unit setVariable [QEGVAR(main,currentTarget), objNull, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Tactics Assess", EGVAR(main,debug_functions)];

// gather data
private _unitCount = count units _unit;     // how many soldiers the leader believes he is leading - nk
private _enemies = (_unit targets [true, 1200]) select {_unit knowsAbout _x > 1};
private _plan = [];

// leader assess EH
[QGVAR(OnAssess), [_unit, _group, _enemies]] call EFUNC(main,eventCallback);

// sort plans
private _pos = [];
if !(_enemies isEqualTo [] || {_unitCount < random 3}) then {

    // get modes
    private _speedMode = speedMode _unit;
    private _combatMode = combatMode _unit;
    private _eyePos = eyePos _unit;

    // communicate
    [_unit, selectRandom _enemies] call EFUNC(main,doShareInformation);

    // vehicle response
    private _tankTarget = _enemies findIf {
        (vehicle _x) isKindOf "Tank"
        && {_unit distance2D _x < 450}
        && {!(terrainIntersectASL [_eyePos, (eyePos _x) vectorAdd [0, 0, 5]])};
    };
    if (_tankTarget != -1 && {!GVAR(disableAIHideFromTanksAndAircraft)} && {!(_speedMode isEqualTo "FULL")}) exitWith {
        private _enemyVehicle = (_enemies select _tankTarget);
        _plan pushBack TACTICS_HIDE;
        _pos = _unit getHideFrom _enemyVehicle;

        // anti-vehicle callout
        private _callout = if (isText (configFile >> "CfgVehicles" >> typeOf _enemyVehicle >> "nameSound")) then {
            getText (configFile >> "CfgVehicles" >> typeOf _enemyVehicle >> "nameSound")
        } else {
            "KeepFocused"
        };
        [_unit, behaviour _unit, _callout, 125] call EFUNC(main,doCallout);
    };

    // anti-infantry tactics
    _enemies = _enemies select {(vehicle _x) isKindOf "Man"};
    private _inside = _unit call EFUNC(main,isIndoor);

    // Check for artillery ~ NB: support is far quicker now! and only targets infantry
    if (EGVAR(main,Loaded_WP) && {[side _unit] call EFUNC(WP,sideHasArtillery)}) then {
        private _artilleryTarget = _enemies findIf {
            _unit distance2D _x > 200
            && {([_unit, getPos _x, 100] call EFUNC(main,findNearbyFriendlies)) isEqualTo []}
        };
        if (_artilleryTarget != -1) then {
            [_unit, _unit getHideFrom (_enemies select _artilleryTarget)] call EFUNC(main,doCallArtillery);   // possibly add delay? ~ nkenny
        };
    };

    // no manoeuvres or no weapons -- exit
    if (
        GVAR(disableAIAutonomousManoeuvres)
        || {weapons _unit isEqualTo []}
        || {!(_unit checkAIFeature "PATH")}
        || {!(_unit checkAIFeature "MOVE")}
    ) exitWith {_plan = [];};

    // enemies within X meters of leader and either attacker or unit is inside buildings
    private _nearIndoorTarget = _enemies findIf {
        _unit distance2D _x < 25
        && {_inside || {_x call EFUNC(main,isIndoor)}}
    };
    if (_nearIndoorTarget != -1) exitWith {
        _plan append [TACTICS_GARRISON, TACTICS_ASSAULT, TACTICS_ASSAULT];
        _pos = [_unit getHideFrom (_enemies select _nearIndoorTarget), getPosASL _unit] select _inside;
    };

    // inside? stay safe
    if (_inside) exitWith {_plan = [];};

    // enemies far away and above height and has LOS and limited knowledge!
    private _farHighertarget = _enemies findIf {
        _unit distance2D _x > 300
        && {_unit knowsAbout _x < 2}
        && {(getPosASL _x select 2 ) > ((getPosASL _unit select 2) + 15)}
        && {!(terrainIntersectASL [_eyePos vectorAdd [0, 0, 5], eyePos _x])};
    };
    if (_farHighertarget != -1 && {!(_speedMode isEqualTo "FULL")}) exitWith {
        _plan append [TACTICS_SUPPRESS, TACTICS_HIDE, TACTICS_HIDE];
        _pos = _unit getHideFrom (_enemies select _farHighertarget);
    };

    // enemies near and away from buildings and below
    private _farNoCoverTarget = _enemies findIf {
        _unit distance2D _x < 220
        && {((getPosASL _x) select 2) < ((getPosASL _unit select 2) - 15)}
        && {([_x, GVAR(cqbRange) * 0.55] call EFUNC(main,findBuildings)) isEqualTo []}
    };
    if (_farNoCoverTarget != -1) exitWith {
        // trust in default attack routines!
        _plan pushBack TACTICS_ATTACK;
        _pos = _enemies select _farNoCoverTarget;
    };

    // enemy at long range
    private _farTarget = _enemies findIf {
        _unit distance2D _x > 300
    };
    if (_farTarget != -1) then {
        // suppress or flank
        _plan append [TACTICS_SUPPRESS, TACTICS_SUPPRESS, TACTICS_FLANK];
        if (_speedMode isEqualTo "FULL") then {_plan pushBack TACTICS_ASSAULT;};
        _pos = _unit getHideFrom (_enemies select _farTarget);
    };

    // enemy at inside buildings or fortified
    private _fortifiedTarget = _enemies findIf {
        _x call EFUNC(main,isIndoor)
        || {!((nearestObjects [_x, ["Strategic", "StaticWeapon"], 2, true]) isEqualTo [])}
    };
    if (_fortifiedTarget != -1) exitWith {

        // basic plan
        _plan append [TACTICS_FLANK, TACTICS_FLANK];
        _pos = _unit getHideFrom (_enemies select _fortifiedTarget);

        // combatmode
        if (_combatMode isEqualTo "RED") then {_plan pushBack TACTICS_ASSAULT;};
        if (_combatMode in ["YELLOW", "WHITE"]) then {_plan pushBack TACTICS_SUPPRESS;};

        // visibility / distance / no cover
        if !(terrainIntersectASL [_eyePos, eyePos (_enemies select _fortifiedTarget)]) then {_plan pushBack TACTICS_SUPPRESS;};
        if (_unit distance2D _pos < 120) then {_plan pushBack TACTICS_ASSAULT;};
        if ((nearestTerrainObjects [ _unit, ["BUSH", "TREE", "HOUSE", "HIDE"], 4, false, true ]) isEqualTo []) then {_plan pushBack TACTICS_FLANK;};

        // conceal movement
        [_unit, _pos] call EFUNC(main,doSmoke);
    };
};

// find units
private _units = [_unit] call EFUNC(main,findReadyUnits);

// deploy flares
if (!(GVAR(disableAutonomousFlares)) && {_unit call EFUNC(main,isNight)}) then {
    _units = [_units] call EFUNC(main,doUGL);
};

// man empty static weapons
if !(GVAR(disableAIFindStaticWeapons)) then {
    _units = [_units, _unit] call FUNC(leaderStaticFind);
};

// no plan ~ exit with no executable plan
if (_plan isEqualTo [] || {_pos isEqualTo []}) exitWith {

    // holding tactics
    [_unit] call FUNC(tacticsHold);

    // end
    false
};

// update formation direction ~ enemy pos known!
_unit setFormDir (_unit getDir _pos);

// binoculars if appropriate!
if (RND(0.2) && {(_unit distance2D _pos > 150) && {!(binocular _unit isEqualTo "")}}) then {
    _unit selectWeapon (binocular _unit);
    _unit doWatch _pos;
};

// deploy static weapons
if !(GVAR(disableAIDeployStaticWeapons)) then {
    _units = [_units, _pos] call FUNC(leaderStaticDeploy);
};

// enact plan
_plan = selectRandom _plan;
switch (_plan) do {
    case TACTICS_FLANK: {
        // flank
        [{_this call FUNC(tacticsFlank)}, [_unit, _pos], 22 + random 8] call CBA_fnc_waitAndExecute;
        if !(_units isEqualTo []) then {[_units] call EFUNC(main,doSmoke);};
    };
    case TACTICS_GARRISON: {
        // garrison
        [{_this call FUNC(tacticsGarrison)}, [_unit, _pos], 10 + random 6] call CBA_fnc_waitAndExecute;
    };
    case TACTICS_ASSAULT: {
        // rush ~ assault
        [{_this call FUNC(tacticsAssault)}, [_unit, _pos], 22 + random 8] call CBA_fnc_waitAndExecute;
        if !(_units isEqualTo []) then {[_units] call EFUNC(main,doSmoke);};
    };
    case TACTICS_SUPPRESS: {
        // suppress
        [{_this call FUNC(tacticsSuppress)}, [_unit, _pos], 6 + random 4] call CBA_fnc_waitAndExecute;
    };
    case TACTICS_ATTACK: {
        // group attacks as one
        [{_this call FUNC(tacticsAttack)}, [_unit, _pos], random 1] call CBA_fnc_waitAndExecute;
    };
    default {
        // hide from armor
        [{_this call FUNC(tacticsHide)}, [_unit, _pos, true], random 3] call CBA_fnc_waitAndExecute;
    };
};

// end
true
