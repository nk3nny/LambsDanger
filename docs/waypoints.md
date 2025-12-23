# Waypoints and task modules
This section describes waypoint module functions. For other functions, most of the documentation can be read directly from the GitHub code. The header for each mod includes a description and example of use. Among the _public_ and more utilitarian functions are those pertaining to the unique waypoints added by the mod.  These are described below:

***
**WARNING!**    
TaskX Functions, Waypoints, and Modules must be executed where the AI is local, and the AI _must_ stay on that client. Groups that use dynamic load balancing for headless clients, should switch that off for units running taskX modules.
***
## Advanced parameters
Several tasks have parameters which may need some explanation

### Area
The area parameter in several task functions is used when the task is being called via a module and will be used to further constrain the area of effect within its given radius. Effectively a sub sum of entities within the specified area of the center of the task will be used in the task.

An area is always defined as an array. Each task which has an area parameter uses the default Arma area definition which is as follows:

`[a, b, angle, isRectangle, c]`

> a - area X size / 2 [`<Number>`]\
> b - area Y size / 2 [`<Number>`]\
> angle [`<Number>`]\
> isRectangle [`<Boolean>`]\
> c - area Z size / 2 [`<Number>`]


## Tasks

### taskArtillery
Performs artillery strike at location. Artillery strike has a cone-like 'beaten zone'
> ##### Arguments:
> 0: Artillery unit [`<Object>`]  
> 1: Position targeted [`<Position>`]  
> 2: Caller of strike [`<Object>`]  
> 3: Rounds fired, default 3 - 7 [`<Number>`]  
> 4: Dispersion accuracy, default 100 [`<Number>`]  
> 5: Skip Check Rounds default false [`<Boolean>`]  
```sqf
[cannonBob, getPos angryJoe, bob] spawn lambs_wp_fnc_taskArtillery;
```

### taskArtilleryRegister
Register units as ready artillery pieces
> ##### Arguments:
> 0: Group to check either unit [`<Object>`] or group [`<Group>`]  
```sqf
[group bob] call lambs_wp_fnc_taskArtilleryRegister;
```

### taskAssault
AI Rushes heedlessly to position with an option to be in forced retreat
> ##### Arguments:
> 0: Unit fleeing [`<Object>`]  
> 1: Destination [`<Position>`]  
> 2: Forced retreat, default false [`<Boolean>`]  
> 3: Distance threshold, default 10 [`<Number>`]  
> 4: Update cycle, default 2 [`<Number>`]  
> 5: Is Called for Waypoint, default false [`<Boolean>`]  
```sqf
[bob, getPos angryJoe] spawn lambs_wp_fnc_taskAssault;
```

### taskCamp
Sets the team in camp like behaviour, Larger groups will set out patrols, Turrets may be manned, and Some buildings may be garrisoned
> ##### Arguments:
> 0: Group performing action, either unit [`<Object>`] or [`<Group>`]    
> 1: Central position camp should be made, [`<Position>`]  
> 2: Range of patrols and turrets found, default is 50 meters [`<Number>`]  
> 3: Area the AI Camps in, default [] [`<AREA>`]  
> 4: Teleport Units to Position [`<Boolean>`]  
> 5: Partial group Patrols the Area [`<Boolean>`]  
```sqf
[bob, getPos bob, 50] call lambs_wp_fnc_taskCamp;
```

### taskCQB
Close Combat Module lets AI Group identifies buildings, Clears them methodically, marks building safe, moves to next building and, repeat until no buildings left
> ##### Arguments:
> 0: Group performing action, either unit [`<Object>`] or [`<Group>`]  
> 1: Position targeted [`<Position>`]  
> 2: Radius of search, default 50 [`<Number>`]  
> 3: Delay of cycle, default 21 seconds [`<Number>`]  
> 4: Area the AI Camps in, default [] [`<AREA>`]  
> 5: Is Called for Waypoint, default false [`<Boolean>`]
```sqf
[bob, getPos angryJoe, 50] spawn lambs_wp_fnc_taskCQB;
```

### taskGarrison
The AI will take up building positions and man static weapons within a set range. Units will remain static until a triggered, the trigger may be taking damage, shooting weapons, or being near an enemy fire.
> ##### Arguments:
> 0: Group performing action, either unit [`<Object>`] or [`<Group>`]  
> 1: Position to occupy, default group location [`<Position>`] or [`<Object>`]  
> 2: Range of tracking, default is 50 meters [`<Number>`]  
> 3: Area the AI Camps in, default [] [`<AREA>`]  
> 4: Teleport Units to Position [`<Boolean>`]  
> 5: Sort Based on Height [`<Boolean>`]  
> 6: Exit Conditions that breaks a Unit free (-2 Random, -1 All, 0 None, 1 Hit, 2 Fired, 3 FiredNear, 4 Suppressed), default -2 [`<Number>`]  
> 7: Sub-group patrols the area  [`<Boolean>`]  
```sqf
[bob, bob, 50] call lambs_wp_fnc_taskGarrison;
```

### taskPatrol  
Simple dynamic patrol script by nkenny
Suitable for infantry units (not so much vehicles, boats or air-- that will have to wait!)
> ##### Arguments:
> 0: Group performing action, either unit [`<Object>`] or [`<Group>`]  
> 1: Position being searched, default group position [`<Position>`] or [`<Object>`]  
> 2: Range of tracking, default is 200 meters [`<Number>`]  
> 3: Waypoint Count, default 4  [`<Number>`]  
> 4: Area the AI Camps in, default [] [`<AREA>`]  
> 5: Dynamic patrol pattern, default false [`<Boolean>`]  
> 6: enable dynamic reinforcement [`<Boolean>`]  
> 7: Teleport group to a randomly selected waypoint [`<Boolean>`]  
```sqf
[bob, bob, 500] call lambs_wp_fnc_taskPatrol;
```

### taskDefend
The group defends a position from buildings and selected cover positions.  
The group will not leave the area.
> ##### Arguments:
> 0: Group performing action, either unit [`<Object>`] or [`<Group>`]  
> 1: Position to defend, default group location [`<Position>`] or [`<Object>`]  
> 2: Range the group defends, default is 75 meters [`<Number>`]  
> 3: Area the group defends, default [] [`<AREA>`]  
> 4: Teleport Units to Position [`<Boolean>`]  
> 5: Use trees and stones as additional defensive positions, default is TRUE [`<Boolean>`]  
> 6: Unit is waiting in ambush, default is TRUE [`<Boolean>`]  
> 7: Group sets a sub-unit to Patrol the area [`<Boolean>`]
```sqf
[bob, bob, 50] spawn lambs_wp_fnc_taskDefend;
```

### taskReset
A Function which resets units, canceling garrisons, waypoints an all animation phases
> ##### Arguments:
> 0: Group performing action, either unit [`<Object>`] or [`<Group>`]  
> 1: Soft reset where group variable name is not replaced [`<Boolean>`]  
> 2: Reset waypoints in soft reset mode [`<Boolean>`]
```sqf
[bob] call lambs_wp_fnc_taskReset;
```

## Search Functions
### taskRush
The AI will move with perfect knowledge towards any player unit within range.  While not fearless, the AI is very aggressive and will enter buildings. The AI will know the player location but not targeting information-- the AI must still locate the enemy to start shooting.  Perfect for Black Hawk Down style scenarios or mad dashes through Tanoan jungles.
> ##### Arguments:
> 0: Group performing action, either unit [`<Object>`] or [`<Group>`]  
> 1: Range of tracking, default is 500 meters [`<Number>`]  
> 2: Delay of cycle, default 15 seconds [`<Number>`]  
> 3: Area the AI Camps in, default [] [`<AREA>`]  
> 4: Center Position, if no position or Empty Array is given it uses the Group as Center and updates the position every Cycle, default [] [`<Array>`]  
> 5: Only Players, default true [`<Boolean>`]  
```sqf
[bob, 500] spawn lambs_wp_fnc_taskRush;
```

### taskHunt
An LRRP patrol style script that has the unit slowly patrol in an area which gradually centers on the nearest player, within the defined range. Good for having patrols that must absolutely trigger or when you need to be careful with your AI resources and want only a single patrol which will generate some heat.
> ##### Arguments:
> 0: Group performing action, either unit [`<Object>`] or [`<Group>`]  
> 1: Range of tracking, default is 500 meters [`<Number>`]  
> 2: Delay of cycle, default 15 seconds [`<Number>`]  
> 3: Area the AI Camps in, default [] [`<AREA>`]  
> 4: Center Position, if no position or Empty Array is given it uses the Group as Center and updates the position every Cycle, default [] [`<Array>`]  
> 5: Only Players, default true [`<Boolean>`]  
> 6: Enable dynamic reinforcement [`<Boolean>`]  
> 7: Enable Flare [`<Boolean>`] or [`<Number>`] where 0 disabled, 1 enabled (if Units cant fire it them self a flare is created via createVehicle), 2 Only if Units can Fire UGL them self  
```sqf
[bob, 500] spawn lambs_wp_fnc_taskHunt;
```

### taskCreep
Have the AI stalk, raptor style, the player forces. The group will attempt to move as close as possible before unleashing a hailstorm of fire. Sneaky, stealthy and quite scary.
> ##### Arguments:
> 0: Group performing action, either unit [`<Object>`] or [`<Group>`]  
> 1: Range of tracking, default is 500 meters [`<Number>`]  
> 2: Delay of cycle, default 15 seconds [`<Number>`]  
> 3: Area the AI Camps in, default [] [`<AREA>`]  
> 4: Center Position, if no position or Empty Array is given it uses the Group as Center and updates the position every Cycle, default [] [`<Array>`]  
> 5: Only Players, default true [`<Boolean>`]
```sqf
[bob, 500] spawn lambs_wp_fnc_taskCreep;
```


[`<Object>`]: https://community.bistudio.com/wiki/Object
[`<Number>`]: https://community.bistudio.com/wiki/Number
[`<Array>`]: https://community.bistudio.com/wiki/Array
[`<Position>`]: https://community.bistudio.com/wiki/Position
[`<Group>`]: https://community.bistudio.com/wiki/Group
[`<Boolean>`]: https://community.bistudio.com/wiki/Boolean
[`<AREA>`]: #area