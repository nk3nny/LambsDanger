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
#define RANGE_NEAR 120
#define RANGE_MID 220
#define RANGE_LONG 300
#define RANGE_THREAT 450

params [["_unit", objNull, [objNull]]];

// check if group AI disabled
private _group = group _unit;

// set variable
_group setVariable [QGVAR(isExecutingTactic), true];
_group setVariable [QGVAR(contact), time + 600];
if (isNull objectParent _unit) then {_group enableAttack false;};

// set current task
_unit setVariable [QEGVAR(main,currentTarget), objNull, EGVAR(main,debug_functions)];
_unit setVariable [QEGVAR(main,currentTask), "Tactics Assess", EGVAR(main,debug_functions)];

// get max data range ~ reduced for forests or cities - nkenny
private _pos = getPosATL _unit;
private _range = (850 * (1 - (_pos getEnvSoundController "houses") - (_pos getEnvSoundController "trees") - (_pos getEnvSoundController "forest") * 0.5)) max 120;

// gather data
private _unitCount = count units _unit;
private _enemies = (_unit targets [true, _range]) select {_unit knowsAbout _x > 1};
private _plan = [];

// leader assess EH
[QGVAR(OnAssess), [_unit, _group, _enemies]] call EFUNC(main,eventCallback);

// sort plans
_pos = [];
if !(_enemies isEqualTo [] || {_unitCount < random 4}) then {
    scopeName "conditionScope";

    // sort nearest enemies
    _enemies = _enemies apply {[_x distanceSqr _unit, _x]};
    _enemies sort true;
    _enemies = _enemies apply {_x select 1};

    // get modes
    private _speedMode = (speedMode _unit) isEqualTo "FULL";
    private _eyePos = eyePos _unit;

    // communicate
    [_unit, selectRandom _enemies] call EFUNC(main,doShareInformation);

    // vehicle response
    private _tankTarget = _enemies findIf {
        _unit distance2D _x < RANGE_THREAT
        && {(vehicle _x) isKindOf "Tank"}
        && {!(terrainIntersectASL [_eyePos, (eyePos _x) vectorAdd [0, 0, 5]])}
    };
    if (_tankTarget != -1 && {!GVAR(disableAIHideFromTanksAndAircraft)} && {!_speedMode}) exitWith {
        private _enemyVehicle = _enemies select _tankTarget;
        _plan pushBack TACTICS_HIDE;
        _pos = _unit getHideFrom _enemyVehicle;

        // anti-vehicle callout
        private _nameSoundConfig = configOf _enemyVehicle >> "nameSound";
        private _callout = if (isText _nameSoundConfig) then { getText _nameSoundConfig } else { "KeepFocused" };
        [_unit, behaviour _unit, _callout] call EFUNC(main,doCallout);
    };

    // soft vehicle response
    private _hasAT = ([_group, AI_AMMO_USAGE_FLAG_VEHICLE + AI_AMMO_USAGE_FLAG_ARMOUR] call EFUNC(main,getLauncherUnits)) isNotEqualTo [];
    private _vehicleTarget = _enemies findIf {
        _hasAT
        && {_unit distance2D _x < RANGE_NEAR}
        && {(vehicle _x) isKindOf "LandVehicle"}
    };
    if (_vehicleTarget != -1 && {!_speedMode}) exitWith {
        _plan append [TACTICS_ATTACK, TACTICS_ASSAULT, TACTICS_ASSAULT];
        _pos = _unit getHideFrom (_enemies select _vehicleTarget);
    };

    // anti-infantry tactics
    _enemies = _enemies select {isNull objectParent _x};

    // Check for artillery ~ NB: support is far quicker now! and only targets infantry
    if (EGVAR(main,Loaded_WP) && {[side _unit] call EFUNC(WP,sideHasArtillery)}) then {
        private _artilleryTarget = _enemies findIf {
            _unit distance2D _x > RANGE_MID
            && {([_unit, getPos _x, RANGE_NEAR] call EFUNC(main,findNearbyFriendlies)) isEqualTo []}
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
    private _inside = _unit call EFUNC(main,isIndoor);
    private _nearIndoorTarget = _enemies findIf {
        _unit distance2D _x < RANGE_NEAR
        && {_inside || {_x call EFUNC(main,isIndoor)}}
    };
    if (_nearIndoorTarget != -1) exitWith {
        _plan append [TACTICS_ASSAULT, TACTICS_ASSAULT];
        _pos = _unit getHideFrom (_enemies select _nearIndoorTarget);
    };

    // unit has HOLD waypoint
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

    // enemies near and below
    /*
    private _farNoCoverTarget = _enemies findIf {
        _unit distance2D _x < RANGE_MID
        && {((getPosASL _x) select 2) < ((_eyePos select 2) - 15)}
        && {!(_x call EFUNC(main,isIndoor))}
    };
    if (_farNoCoverTarget != -1) exitWith {
        // trust in default attack routines!
        _plan pushBack TACTICS_ATTACK;
        _pos = _enemies select _farNoCoverTarget;
    };
    */

    // enemy at inside buildings or fortified or far
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

// man empty static weapons and deploy static weapons
if !(GVAR(disableAIFindStaticWeapons)) then {
    _units = [_units, _unit] call EFUNC(main,doGroupStaticFind);
    _units = [_units, _pos] call EFUNC(main,doGroupStaticDeploy);
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
if (
    RND(0.2)
    && {(_unit distance2D _pos > RANGE_MID)
    && {(binocular _unit) isNotEqualTo ""}}
    && {!(_unit call EFUNC(main,isIndoor))}
) then {
    _unit selectWeapon (binocular _unit);
    _unit doWatch _pos;
};

// enact plan
_plan = selectRandom _plan;
switch (_plan) do {
    case TACTICS_FLANK: {
        // flank
        [{_this call FUNC(tacticsFlank)}, [_group, _pos, _units], 22 + random 8] call CBA_fnc_waitAndExecute;
    };
    case TACTICS_GARRISON: {
        // garrison ~ nb units not carried here - nkenny
        [{_this call FUNC(tacticsGarrison)}, [_group, _pos], 10 + random 6] call CBA_fnc_waitAndExecute;
    };
    case TACTICS_ASSAULT: {
        // rush ~ assault
        [{_this call FUNC(tacticsAssault)}, [_group, _pos], 6 + random 8] call CBA_fnc_waitAndExecute;
    };
    case TACTICS_SUPPRESS: {
        // suppress
        [{_this call FUNC(tacticsSuppress)}, [_group, _pos, _units], 4 + random 4] call CBA_fnc_waitAndExecute;
    };
    case TACTICS_ATTACK: {
        // group attacks as one
        [{_this call FUNC(tacticsAttack)}, [_group, _pos, _units], 1 + random 1] call CBA_fnc_waitAndExecute;
    };
    default {
        // hide from armor
        [{_this call FUNC(tacticsHide)}, [_group, _pos, true], 1 + random 3] call CBA_fnc_waitAndExecute;
    };
};

// end
true
