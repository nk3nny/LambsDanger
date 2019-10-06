#include "script_component.hpp"
/*
 * Author: jokoho482
 * Returns Overwatch Positions
 *
 * Warning:
 * It is possible that this function does not Generate any Posisions and Returns a Empty Array!
 *
 * Arguments:
 * 0: Target Position <Vector3>
 * 1: Position from where to search from <Vector3>
 * 2: Mininal Distance From Position <Number>
 * 3: Maximal Distance From Position <Number>
 * 4: Respect incidence Angle <Boolean> (Default: false)
 * 5: Incidence Angle MinMax <Vector2> (Default: [15, 60])
 * 6: Max Results <Number> (Default: -1)
 *
 * Return Value:
 * Array of Position of a Possible Overwatch Position
 *
 * Example:
 * [bob, 10, 50] call lambs_danger_fnc_findOverwatch;
 *
 * Public: Yes
*/
scriptName QGVAR(findOverwatch);
scopeName QGVAR(findOverwatch);

params ["_targetPos", "_originPos", "_min", "_max", ["_respectIncidenceAngle", false], ["_incidenceAngleMinMax", [15, 60]], ["_maxResults", -1]];

private _posASL = (AGLToASL(_targetPos) vectorAdd [0,0, getTerrainHeightASL _targetPos + 1]);
private _possiblePos = [];
{
    private _checkPos = locationPosition _x;
    private _distance = _checkPos distance2D _targetPos;
    private _validPos = (_distance > _min) && {_distance < _max};
    if (_validPos && _respectIncidenceAngle) then {
        private _height = (getTerrainHeightASL _checkPos) - (getTerrainHeightASL _targetPos);
        private _incidenceAngle = _height atan2 _distance;
        _validPos = _validPos && _height > 20 || (_incidenceAngle < (_incidenceAngleMinMax select 1) && _incidenceAngle > (_incidenceAngleMinMax select 0));
    };
    if (_validPos) then {
        private _lis = lineIntersectsSurfaces [_posASL, AGLToASL(_checkPos), objNull, objNull, true, -1, "NONE", "NONE"];
        if (_lis isEqualTo []) then {
            _possiblePos pushback _checkPos;
            if (_maxResults != -1 && {(count _possiblePos) == _maxResults}) then {
                _possiblePos breakOut QGVAR(findOverwatch);
            };
        };
    };
} count (nearestLocations [_originPos, ["Hill", "Mount"], _max]);
_possiblePos
