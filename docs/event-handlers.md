# Event Handlers
Event handlers are a framework where code is triggered when some event occurs. The vanilla game comes with a [large number](https://community.bistudio.com/wiki/Arma_3:_Event_Handlers) and LAMBS Danger FSM extends this further.
All Lambs Danger Events are _local_ to the unit.

## CBA Event handlers
Event handlers are added via the [CBA Eventhandler Interface](https://github.com/CBATeam/CBA_A3/wiki/Custom-Events-System).

## BIS Scripted Event handlers
If you want Targeted Events for only the Unit or Group that is effected you can add that via [BIS SciptedEventHandlers](https://community.bistudio.com/wiki/BIS_fnc_addScriptedEventHandler) Requires: 2.4.0 or later

## LAMBS specific event handlers
Name | Arguments | Description  
---|---|---
lambs_main_OnCheckBody | _unit [`<Object>`], _groupOfUnit [`<Group>`], _body [`<Object>`] | Called when a Units Checks a Body
lambs_danger_OnArtilleryCalled | _unitThatCalledArtillery [`<Object>`], _groupOfUnit [`<Group>`], _ArtilleryGun [`<Object>`], _TargetPosition [`<Position>`] | Called when a Squad Leader Calls Artillery Support
lambs_danger_OnAssess | _unit [`<Object>`], _groupOfUnit [`<Group>`], _enemys [`<Array>`] of [`<Object>`]| Called when a Leader assess the current Situation
lambs_danger_OnContact | _unit [`<Object>`], _groupOfUnit [`<Group>`], _target [`<Object>`]| Called when a Leader gets into Contact
lambs_main_OnPanic | _unit [`<Object>`], _groupOfUnit [`<Group>`] | Called when a Unit falls into the Panic State
lambs_main_OnInformationShared | _unit [`<Object>`], _groupOfUnit [`<Group>`], _target [`<Object>`], _groups [`<Array>`] of [`<Group>`]| Called when a Unit Shares Informations
lambs_main_OnFleeing | _unit [`<Object>`], _groupOfUnit [`<Group>`] | Called when a Unit falls into a Fleeing State
lambs_danger_OnReinforce | _unit [`<Object>`], _groupOfUnit [`<Group>`], _target [`<Object>`] or [`<Position>`] | Called when a Unit is starting reinforcement maneuver

### Example of use
#### CBA Event handlers
```sqf
["lambs_danger_OnPanic", {
    params ["_unit", "_group"];
    _unit playAction "Surrender";
}] call CBA_fnc_addEventHandler;
```
#### BIS Scripted Event handlers<
Requires: 2.4.0 or later
```sqf
[bob, "lambs_danger_OnPanic", {
    params ["_unit", "_group"];
    _unit playAction "Surrender";
}] call BIS_fnc_addScriptedEventHandler;
```

## Pre-2.0 variables
If you came to the mod before CBA implementation, you may be familiar with the group variable "lambs_code". This is now defunct and deprecated having been replaced by the event handlers demonstrated above.

[`<Object>`]: https://community.bistudio.com/wiki/Object
[`<Number>`]: https://community.bistudio.com/wiki/Number
[`<Array>`]: https://community.bistudio.com/wiki/Array
[`<Position>`]: https://community.bistudio.com/wiki/Position
[`<Group>`]: https://community.bistudio.com/wiki/Group
[`<Boolean>`]: https://community.bistudio.com/wiki/Boolean
