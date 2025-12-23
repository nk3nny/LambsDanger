# Unit and Group Variables
Use unit and group variables to deactivate certain mod aspects and read information from the mod. 

### Group variables
Group leaders are equipped with an extra layer of AI. The group or tactical assessment component covers such things as calling for artillery, coordinated building assaults, hiding from tanks or airplanes, remanning static weapons, scanning with binoculars, and additional levels of extra-group communication.

```sqf
<group> setVariable ["lambs_danger_disableGroupAI", true];
```

### Unit variables
The enhanced behaviours of the mod are easily toggled. The unit FSM may be dynamically deactivated during play. The individual AI handles such things as entering buildings, the reaction state to combat, panicking and various other core LAMBS Danger FSM features.

```sqf
<unit> setVariable ["lambs_danger_disableAI", true];
```

### Formation variable
With the group AI active it is possible to configure formation changes on first contact. The formation change is run on the 'Contact' event. Possible uses could be to change the unit from a patrolling formation to a CQC mode, or some other preferred variation.

```sqf
<group> setVariable ["lambs_danger_dangerFormation", "FILE"];
```

### Has Radio variable
When a unit shares information about an enemy with nearby groups, they can do so over radio as well. This will effectively increase the range of their report as it will use the radio range set inside the Addon Options menu. It is possible to set the radio flag on a unit as follows.

```sqf
<unit> setVariable ["lambs_danger_dangerRadio", true];
```

***
## Reinforcements
Reinforcing groups will make simple pre-battle assessments and may deploy or pack static weapons, change formations, or other acts of reorganisation. As always, it is non-invasive and is only activated on groups set by the mission maker.

Use is easy. Set a variable on the group, and this unit will now respond when allies within radio communication range call for help. Setting the variable can be done in multiple ways: Either through Zeus modules, Eden settings, or writing it directly to the group.
```sqf
<group> setVariable ["lambs_danger_enableGroupReinforce", true, true];
```
Groups with the reinforcement variable set will respond to friendly information sharing events. If the enemy is known, they will move towards that location. If not, they will move to the unit calling for help.

Groups will act with increased autonomy. Based on the distance and visibility of the enemy they will: Adopt formation changes. Shoot flares. Pack and unpack carried static weapons. More types of behaviour will be added in the future. Be aware that the reinforcement feature may override existing waypoints based on the context of the situation.

The level of emergent play can be enhanced by attaching more checks to the eventhandler: “lambs_main_onReinforce”. As per our design philosophy, the default implementation remains seamless. You won’t see AI randomly stealing cars or wandering away from their assigned tasks!

***
## Tactics and contacts
Check these variables to determine if a unit is currently executing a group tactic or how long the contact state will last:   

```sqf
<group> getVariable "lambs_danger_isExecutingTactic"
<group> getVariable "lambs_danger_contact"
```

***
## Debug variables
_NB: These variables will only come into play at version 2.5 or later._

### FSM Danger cause data
Checking this variable will give the current FSM data that the AI is responding to. 

```sqf
<unit> getVariable "lambs_main_FSMDangerCauseData"
```

> ##### returns [`<ARRAY>`]:
> 0: Cause of danger [`<NUMBER>`]    
> 1: Position of Danger [`<ARRAY>`]     
> 2: Danger lasting until [`<NUMBER>`]  
> 3: Dangerous object [`<OBJECT>`] (OBS: is sometimes [`objNull`])  


### Feedback
The following three variables will report various information about the unit and group tasks:  
```sqf
<unit> getVariable "lambs_main_currentTarget"
<unit> getVariable "lambs_main_currentTask"
<group> getVariable "lambs_main_currentTactic"
```

[`<Object>`]: https://community.bistudio.com/wiki/Object
[`<Number>`]: https://community.bistudio.com/wiki/Number
[`<Array>`]: https://community.bistudio.com/wiki/Array
[`<Position>`]: https://community.bistudio.com/wiki/Position
[`<Group>`]: https://community.bistudio.com/wiki/Group
[`<Boolean>`]: https://community.bistudio.com/wiki/Boolean
[`objNull`]: https://community.bistudio.com/wiki/objNull