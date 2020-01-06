#include "script_component.hpp"

params ["_logic", "", "_activated"];

if (_activated && local _logic) then {

    //--- Terminate when remote control is already in progress
    if !(isNull (missionNamespace getVariable ["bis_fnc_moduleRemoteControl_unit", objNull])) exitWith {};

    //--- Get unit under cursor
    private _group = grpNull;
    private _mouseOver = missionNamespace getVariable ["BIS_fnc_curatorObjectPlaced_mouseOver", [""]];
    if ((_mouseOver select 0) isEqualTo (typeName objNull)) then { _group = group (effectiveCommander (_mouseOver select 1)); };
    if ((_mouseOver select 0) isEqualTo (typeName grpNull)) then { _group = _mouseOver select 1; };

    if (isNull _group) then {
        private _groups = allGroups;
        ["Task Rush Waypoint",
            [
                ["Group", "LIST", "The Group the Waypoint gets Added to", _groups apply {str _x}, 0],
                ["Waypoint Radius", "INTEGER", "WHAT???", 1000] // TODO: Tooltip
            ], {
                params ["_data", "_args"];
                _data params ["_groupIndex", "_radius"];
                _args params ["_targetPos", "_groups", "_logic"];
                private _group = _groups select _groupIndex;
                private _wp = _group addWaypoint [_targetPos, 0];
                _wp setWaypointScript getText (configFile >> "CfgWaypoints" >> "LAMBS_DangerAI" >> QEGVAR(danger,Rush) >> file);
                _wp setWaypointCompletionRadius _radius;
                deleteVehicle _logic;
            }, {}, {}, [getPos _logic, _groups, _logic]
        ] call EFUNC(main,showDialog);
    } else {
        private _targets = entities QGVAR(Waypoint_Target);
        if (_targets isEqualTo []) exitWith {
            [objNull, "ERROR: No Waypoint Targets Found"] call BIS_fnc_showCuratorFeedbackMessage;
            deleteVehicle _logic;
        };
        ["Task Rush Waypoint",
            [
                ["Target Position", "LIST", "The Target Position", _targets apply {format ["X: %1 Z: %2", (getPos _x) select 0, (getPos _x) select 1]}], // TODO: finde a besser way for Descripting Position and name.
                ["Waypoint Radius", "INTEGER", "WHAT???", 1000] // TODO: Tooltip
            ], {
                params ["_data", "_args"];
                _data params ["_targetIndex", ["_radius", 1000]];
                _args params ["_group", "_groups", "_logic"];
                private _wp = _group addWaypoint [_targetPos, 0];
                _wp setWaypointScript getText (configFile >> "CfgWaypoints" >> "LAMBS_DangerAI" >> QEGVAR(danger,Rush) >> file);
                _wp setWaypointCompletionRadius _radius;
                deleteVehicle _logic;
            }, {}, {}, [_group, _targets, _logic]
        ] call EFUNC(main,showDialog);
    };
};
