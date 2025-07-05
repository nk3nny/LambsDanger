#include "script_component.hpp"
/*
 * Author: nkenny
 * Group leader assesses situation and calls manoeuvres or support assets as necessary
 * OPTIMIZED VERSION - reduced redundant calculations and improved performance
 */
#define TACTICS_HIDE 0
#define TACTICS_FLANK 1
#define TACTICS_GARRISON 2
#define TACTICS_ASSAULT 3
#define TACTICS_SUPPRESS 4
#define TACTICS_ATTACK 5
#define RANGE_NEAR 120
#define RANGE_MID 220
#define RANGE_LONG 300
#define RANGE_THREAT 450

params [["_unit", objNull, [objNull]]];

// validate unit
if (isNull _unit || {!(_unit call EFUNC(main,isAlive))}) exitWith {
    EGVAR(main,debug_functions) && {["tacticsAssess called with invalid unit"] call EFUNC(main,debugLog)};
    false
};

// check if group AI disabled
private _group = group _unit;

// set variable
_group setVariable [QGVAR(isExecutingTactic), true];
_group setVariable [QGVAR(contact), time + 600];
if (isNull objectParent _unit) then {_group enableAttack false;};

// set current task
_unit setVariable [QEGVAR(main,currentTarget), objNull, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Tactics Assess", EGVAR(main,debug_functions)];

// Cache frequently used values
private _unitPos = getPosATL _unit;
private _eyePos = eyePos _unit;
private _unitCount = count units _unit;
private _speedMode = (speedMode _unit) isEqualTo "FULL";

// get max data range ~ reduced for forests or cities - nkenny
private _range = (850 * (1 - (_unitPos getEnvSoundController "houses") - (_unitPos getEnvSoundController "trees") - (_unitPos getEnvSoundController "forest") * 0.5)) max 120;

// gather data
private _enemies = (_unit targets [true, _range]) select {_unit knowsAbout _x > 1};
private _plan = [];

// leader assess EH
[QGVAR(OnAssess), [_unit, _group, _enemies]] call EFUNC(main,eventCallback);

// sort plans
private _pos = [];
if !(_enemies isEqualTo [] || {_unitCount < random 4}) then {
    scopeName "conditionScope";

    // sort nearest enemies ONCE and cache distances
    private _enemyDistances = [];
    {
        private _dist = _x distanceSqr _unit;
        _enemyDistances pushBack [_dist, _x];
    } forEach _enemies;
    _enemyDistances sort true;
    _enemies = _enemyDistances apply {_x select 1};

    // communicate
    [_unit, selectRandom _enemies] call EFUNC(main,doShareInformation);

    // vehicle response - check for tanks first (most dangerous)
    private _tankTarget = -1;
    private _vehicleTarget = -1;
    private _hasAT = false;
    
    {
        private _enemy = _x;
        private _vehicle = vehicle _enemy;
        private _dist2D = sqrt (_enemyDistances select _forEachIndex select 0); // Use cached distance
        
        if (_tankTarget == -1 && _vehicle isKindOf "Tank" && _dist2D < RANGE_THREAT) then {
            if (!(terrainIntersectASL [_eyePos, (eyePos _enemy) vectorAdd [0, 0, 5]])) then {
                _tankTarget = _forEachIndex;
            };
        };
        
        // Check for soft vehicles while we're iterating
        if (_vehicleTarget == -1 && _vehicle isKindOf "LandVehicle" && !(_vehicle isKindOf "Tank") && _dist2D < RANGE_NEAR) then {
            if (!_hasAT) then { // Only check once
                _hasAT = ([_group, AI_AMMO_USAGE_FLAG_VEHICLE + AI_AMMO_USAGE_FLAG_ARMOUR] call EFUNC(main,getLauncherUnits)) isNotEqualTo [];
            };
            if (_hasAT) then {
                _vehicleTarget = _forEachIndex;
            };
        };
    } forEach _enemies;

    // Handle tank threat
    if (_tankTarget != -1 && {!GVAR(disableAIHideFromTanksAndAircraft)} && {!_speedMode}) exitWith {
        private _enemyVehicle = _enemies select _tankTarget;
        _plan pushBack TACTICS_HIDE;
        _pos = _unit getHideFrom _enemyVehicle;

        // anti-vehicle callout
        private _nameSoundConfig = configOf _enemyVehicle >> "nameSound";
        private _callout = if (isText _nameSoundConfig) then { getText _nameSoundConfig } else { "KeepFocused" };
        [_unit, behaviour _unit, _callout] call EFUNC(main,doCallout);
    };

    // Handle soft vehicle threat
    if (_vehicleTarget != -1 && {!_speedMode}) exitWith {
        _plan append [TACTICS_ATTACK, TACTICS_ASSAULT, TACTICS_ASSAULT];
        _pos = _unit getHideFrom (_enemies select _vehicleTarget);
    };

    // anti-infantry tactics - filter out vehicle crews
    _enemies = _enemies select {isNull objectParent _x};

    // Check for artillery ~ NB: support is far quicker now! and only targets infantry
    if (EGVAR(main,Loaded_WP) && {[side _unit] call EFUNC(WP,sideHasArtillery)}) then {
        private _artilleryTarget = _enemies findIf {
            _unit distance2D _x > RANGE_MID
            && {([_unit, getPos _x, RANGE_NEAR] call EFUNC(main,findNearbyFriendlies)) isEqualTo []}
        };
        if (_artilleryTarget != -1) then {
            [_unit, _unit getHideFrom (_enemies select _artilleryTarget)] call EFUNC(main,doCallArtillery);
        };
    };

    // no manoeuvres or no weapons -- exit
    if (
        GVAR(disableAIAutonomousManoeuvres)
        || {weapons _unit isEqualTo []}
        || {!(_unit checkAIFeature "PATH")}
        || {!(_unit checkAIFeature "MOVE")}
    ) exitWith {_plan = [];};

    // Cache indoor status
    private _inside = _unit call EFUNC(main,isIndoor);
    
    // enemies within X meters of leader and either attacker or unit is inside buildings
    private _nearIndoorTarget = _enemies findIf {
        _unit distance2D _x < RANGE_NEAR
        && {_inside || {_x call EFUNC(main,isIndoor)}}
    };
    if (_nearIndoorTarget != -1) exitWith {
        _plan append [TACTICS_ASSAULT, TACTICS_ASSAULT];
        _pos = _unit getHideFrom (_enemies select _nearIndoorTarget);
    };

    // unit has HOLD waypoint - cache waypoint check
    private _waypoints = waypoints _group;
    if (_waypoints isNotEqualTo []) then {
        private _currentWP = _waypoints select ((currentWaypoint _group) min ((count _waypoints) - 1));
        private _holdWP = ((waypointType _currentWP) isEqualTo "HOLD") && {(waypointPosition _currentWP) distance2D _unit < RANGE_MID};
        if (_holdWP) exitWith {
            _plan append [TACTICS_HIDE, TACTICS_HIDE];
            _pos = waypointPosition _currentWP;
            breakOut "conditionScope";
        };
    };

    // inside? stay safe
    if (_inside) exitWith {_plan = [];};

    // enemies far away and above height and has LOS and limited knowledge!
    private _farHighertarget = _enemies findIf {
        !_speedMode
        && {_unit distance2D _x > RANGE_LONG}
        && {_unit knowsAbout _x < 2}
        && {((getPosASL _x) select 2) > ((_eyePos select 2) + 15)}
        && {!(terrainIntersectASL [_eyePos vectorAdd [0, 0, 5], eyePos _x])}
    };
    if (_farHighertarget != -1) exitWith {
        _plan append [TACTICS_SUPPRESS, TACTICS_HIDE, TACTICS_HIDE];
        _pos = _unit getHideFrom (_enemies select _farHighertarget);
    };

    // enemy inside buildings or fortified or far
    private _fortifiedTarget = _enemies findIf {
        _unit distance2D _x > RANGE_LONG
        || {_x call EFUNC(main,isIndoor)}
        || {(nearestObjects [_x, ["Strategic", "StaticWeapon"], 2, true]) isNotEqualTo []}
    };
    if (_fortifiedTarget != -1) exitWith {

        // basic plan
        _plan append [TACTICS_FLANK, TACTICS_FLANK, TACTICS_SUPPRESS];
        _pos = _unit getHideFrom (_enemies select _fortifiedTarget);

        // combatmode
        private _combatMode = combatMode _unit;
        if (_combatMode isEqualTo "RED") then {_plan pushBack TACTICS_ASSAULT;};
        if (_combatMode isEqualTo "YELLOW") then {_plan pushBack TACTICS_SUPPRESS;};
        if (_speedMode) then {
            _plan = _plan - [TACTICS_SUPPRESS];
            _plan pushBack TACTICS_ASSAULT;
        };

        // visibility / distance / no cover
        if !(terrainIntersectASL [_eyePos, eyePos (_enemies select _fortifiedTarget)]) then {_plan pushBack TACTICS_SUPPRESS;};
        if (_unit distance2D _pos < RANGE_MID) then {_plan pushBack TACTICS_ASSAULT;};
        if ((nearestTerrainObjects [ _unit, ["BUSH", "TREE", "HOUSE", "HIDE"], 4, false, true ]) isEqualTo []) then {_plan pushBack TACTICS_FLANK;};

        // conceal movement
        if (!GVAR(disableAutonomousSmokeGrenades)) then {[_unit, _pos] call EFUNC(main,doSmoke);};
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
    _units = [_units, _unit] call EFUNC(main,doGroupStaticFind);
};

// no plan ~ exit with no executable plan
if (_plan isEqualTo [] || {_pos isEqualTo []}) exitWith {
    // holding tactics
    [_unit] call FUNC(tacticsHold);
    false
};

// update formation direction ~ enemy pos known!
_unit setFormDir (_unit getDir _pos);

// binoculars if appropriate!
if (
    RND(0.2)
    && {(_unit distance2D _pos > RANGE_MID)
    && {(binocular _unit) isNotEqualTo ""}}
    && {!_inside} // Use cached value
) then {
    _unit selectWeapon (binocular _unit);
    _unit doWatch _pos;
};

// deploy static weapons
if !(GVAR(disableAIDeployStaticWeapons)) then {
    _units = [_units, _pos] call EFUNC(main,doGroupStaticDeploy);
};

// enact plan
_plan = selectRandom _plan;
switch (_plan) do {
    case TACTICS_FLANK: {
        [{_this call FUNC(tacticsFlank)}, [_group, _pos, _units], 22 + random 8] call CBA_fnc_waitAndExecute;
    };
    case TACTICS_GARRISON: {
        [{_this call FUNC(tacticsGarrison)}, [_group, _pos], 10 + random 6] call CBA_fnc_waitAndExecute;
    };
    case TACTICS_ASSAULT: {
        [{_this call FUNC(tacticsAssault)}, [_group, _pos], 6 + random 8] call CBA_fnc_waitAndExecute;
    };
    case TACTICS_SUPPRESS: {
        [{_this call FUNC(tacticsSuppress)}, [_group, _pos, _units], 4 + random 4] call CBA_fnc_waitAndExecute;
    };
    case TACTICS_ATTACK: {
        [{_this call FUNC(tacticsAttack)}, [_group, _pos, _units], 1 + random 1] call CBA_fnc_waitAndExecute;
    };
    default {
        [{_this call FUNC(tacticsHide)}, [_group, _pos, true], 1 + random 3] call CBA_fnc_waitAndExecute;
    };
};

true
