#include "script_component.hpp"
/*
 * Author: nkenny
 * Actualises flanking cycle
 *
 * Arguments:
 * 0: group conducting the flanking <GROUP>
 * 1: units list <ARRAY>
 * 2: list of group vehicles <ARRAY>
 * 3: list of building/enemy positions <ARRAY>
 * 4: destination <ARRAY>
 *
 * Return Value:
 * bool
 *
 * Example:
 * [units bob] call lambs_main_fnc_doGroupFlank;
 *
 * Public: No
*/
params [["_group", grpNull], ["_units", []], ["_vehicles", []], ["_posList", []], ["_overwatch", [0, 0, 0]], ["_teamAlpha", 0]];

// exit!
if !(_group getVariable [QEGVAR(danger,isExecutingTactic), false]) exitWith {false};

// update
_units = _units select { !( _x getVariable [QEGVAR(danger,disableAI), false] ) && { _x call FUNC(isAlive) } && { !isPlayer _x } };
_vehicles = _vehicles select { canFire _x };

// group has reached destination
private _leader = leader _group;
if ( _leader distance2D _overwatch < 10 ) exitWith {
    _group setVariable [QEGVAR(danger,isExecutingTactic), false];
    _group setVariable [QGVAR(groupMemory), _posList, false];
};

// leader has no friendlies within 35 meters
private _distanceSqr = _leader distanceSqr _overwatch;
private _leaderAlone = ( ( _units - crew _leader) findIf { _x distanceSqr _leader < 1225 || { _x distanceSqr _overwatch < _distanceSqr }} ) isEqualTo -1;

[_posList, true] call CBA_fnc_shuffle;
private _index = -1;
{
    private _unit = _x;
    private _suppressed = (getSuppression _unit) > 0.5;
    private _activeTeam = (_forEachIndex % 2) isEqualTo _teamAlpha;

    // stance
    private _unitPos = call {
        if (_leaderAlone && {_unit isEqualTo _leader}) exitWith {"DOWN"};
        private _crouched = (stance _unit) isEqualTo "CROUCH";
        if (_suppressed) exitWith {["UP", "DOWN"] select _crouched};
        if (_crouched && _activeTeam) exitWith {"UP"};
        "MIDDLE"
    };
    _unit setUnitPos _unitPos;
    _unit setVariable [QEGVAR(danger,forceMove), !_suppressed];

    // move
    _unit doMove (_overwatch vectorAdd [_forEachIndex, _forEachIndex, 0]);
    _unit setVariable [QGVAR(currentTask), "Group Flank", GVAR(debug_functions)];

    // check suppress position
    if (_activeTeam && _index isEqualTo -1) then {
        _index = [_x, _posList] call FUNC(checkVisibilityList);
    };

    // suppress
    if (
        _activeTeam
        && {!(_leaderAlone && {isNull (objectParent (effectiveCommander _leader))})}
        && {(currentCommand _unit) isNotEqualTo "Suppress"}
        && {_unit isNotEqualTo _leader}
        && {_index isNotEqualTo -1}
    ) then {

        // shoot
        private _suppressing = [_unit, AGLToASL ((_posList select _index) vectorAdd [0, 0, random 1])] call FUNC(doSuppress);
        _unit setVariable [QGVAR(currentTask), "Group Flank - Suppress", GVAR(debug_functions)];
        if (!_suppressing) then {
            _index = -1;
        };

    };

} forEach _units;

// reset alpha status
_teamAlpha = parseNumber (_teamAlpha isEqualTo 0);

// vehicles
_vehicles doWatch (selectRandom _posList);
[_posList, true] call CBA_fnc_shuffle;

// reset visibility index
_index = -1;
{

    // check if vehicle is 55m away from friendlies
    private _vehicle = _x;
    private _vehicleLeader = (vehicle _leader) isEqualTo _vehicle;
    private _vehicleAlone = _vehicle distance2D _overwatch > 25 && {( _units findIf { _x distanceSqr _vehicle < 3025 } ) isEqualTo -1};
    private _forceMove = false;

    // check for aggressive vehicle usage
    if (
        ( _vehicleAlone && _vehicleLeader )
        || { count (crew _vehicle) > 3 }
        || { !_vehicleLeader && { _leader distance2D _overwatch < 65 } }
    ) then {
        _forceMove = true;
    };

    // sort out vehicles
    if (!_forceMove && {_index isEqualTo -1}) then {_index = [_vehicle, _posList] call FUNC(checkVisibilityList);};

    // found good target - do suppressive fire
    if (!_forceMove && _index isNotEqualTo -1) then {

        // debug variable
        (effectiveCommander _vehicle) setVariable [QGVAR(currentTask), "Group Flank - Suppressing!", GVAR(debug_functions)];

        // execute suppression - on failed- reset index
        private _suppressing = [_vehicle, _posList select _index] call FUNC(doVehicleSuppress);
        if (!_suppressing) then {
            _index = -1;
        };
    };

    // vehicles move up to support friendly troops
    if (_forceMove || _vehicleAlone || _leaderAlone || {_index isEqualTo -1}) then {

        // debug variable
        (effectiveCommander _vehicle) setVariable [QGVAR(currentTask), "Group Flank - Manoeuvring!", GVAR(debug_functions)];

        // move up behind leader
        private _movePos = call {

            // forcemove
            if (_forceMove) exitWith {_overwatch};

            // leader vehicles move forward referring themselves
            if (_vehicleLeader) exitWith {_vehicle getPos [35, _vehicle getDir _overwatch]};

            // vehicle closer than leader is
            if ((_vehicle distance2D _overwatch) < (_leader distance2D _overwatch)) exitWith {_overwatch};

            // if not. Find a position behind the leader
            _leader getPos [35 min (_vehicle distance2D _leader), (_overwatch getDir _leader) + (90 * _forEachIndex)]
        };

        // adjust for vehicle
        private _adjustPos = _movePos findEmptyPosition [5, 35, typeOf _vehicle];
        if (_adjustPos isNotEqualTo []) then {_movePos = _adjustPos};

        // give move order specifically to driver (seems to help for some reason)
        (driver _vehicle) doMove _movePos;
    };

} forEach _vehicles;

// recursive cyclic
if (_units isNotEqualTo [] && { _group getVariable [QEGVAR(danger,isExecutingTactic), false] }) then {
    [
        {_this call FUNC(doGroupFlank)},
        [_group, _units, _vehicles, _posList, _overwatch, _teamAlpha],
        11 + random 8
    ] call CBA_fnc_waitAndExecute;
};

// end
true
