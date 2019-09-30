#include "script_component.hpp"
// Task Camp (defense)
// version 2.1
// by nkenny


/*
Nice little halfcircle of troops
populate one turret and one building if nearby. 

v1.0 ~ straight outta MercTales
- 17.06.15

v1.1 ~ 30.06.15
- Increased range slightly 40-50meters
- Added while loop to smarten script-- more units in defensive positions
- Attempted bugfix to get bunkers added! 

v1.2 ~ 07.07.15
- Add Patrols to camps
- if leader enters danger mode-- the entire team goes into GUARD mode. Not sure this works
- Added whistle mode. LOLLOLOLOL

v1.3 ~ 18.06.16
- Moved to /BASE project LIZARD

v1.4 ~ 22.07.16
- Changed to SelectRandom
- Small script tweaks

v1.5 ~ 20.06.17
- Major performance tweaks
- Removed BIS function

v2.0 ~ 07.10.2018
- You've come a long way baby
- Smarter population script
- Cleaner code

v2.1 ~ 09.07.19
- Added eventhandler to check for hits 
- Minor code clean ups
 
future? 
- Make population script smarter
*/

// init
private _grp = param [0];
private _r = param [1,62];

// sort grp --- 
if (!local _grp) exitWith {};
_grp = [_grp] call {if (typeName _grp == "OBJECT") exitWith {group _grp};_grp}; 
_units = units _grp;

// orders ---
_grp setBehaviour "SAFE";
_grp setSpeedMode "LIMITED";
_grp setCombatMode "YELLOW";
_grp setFormation selectRandom ["STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "DIAMOND"];
//_grp enableGunLights "forceOn";

// pos
private _p = getpos leader _grp; 

// find buildings ---
_b = nearestobjects [_p,["house","strategic"],_r,true];
_b = _b select {count (_x buildingpos -1) > 0};
_b = _b call BIS_fnc_arrayShuffle;

// find guns ---
_g = nearestobjects [_p,["Landvehicle"],_r,true];
_g = _g select {(_x emptyPositions "Gunner") > 0};

// STAGE 1 - PATROL --------------------------

if (count _units > 4) then 
  {
  _grp2 = createGroup (side _grp);
  [selectRandom units _grp] join _grp2;
  if (count _units > 6)  then {[selectRandom units _grp] join _grp2;};

  // performance
  _grp2 enableDynamicSimulation true;
  _grp2 deleteGroupWhenEmpty true;

  // id 
  _grp2 setGroupIDGlobal [format ["Patrol (%1)",groupId _grp2]];
  
  // orders
  [_grp2,_r*2] spawn nk_fnc_taskPatrol; 
  
  // update
  _units = units _grp;   
  }; 

// STAGE 2 - GUNS & BUILDINGS ---------------
{
  // gun
  if (count _g > 0) then 
    {
    _x moveInGunner (_g select 0);
    _g deleteAt 0;
    _units deleteAt _foreachIndex;
    }; 
    
  if (count _b > 0 && {random 1 > 0.3}) then 
    {
    doStop _x; 
    _x setUnitPos "UP";
    _x setPos selectRandom ((_b select 0) buildingPos -1);
    _b deleteAt 0; 
    _units deleteAt _foreachIndex;
    }; 
    
  if (count _units < count units _grp/2) exitWith {}; 

} foreach _units; 

// STAGE 3 - STAND ABOUT ----------------
{
  _d = random 360;
  _r = 1.3 + random 3.3;
  _p2 = [(_p select 0) + (sin _d) * _r, (_p select 1) + (cos _d) * _r, 0];
  _x setdir (random 360);
  _x setpos _p2;
  _x disableAI "ANIM"; 
  _anim = selectRandom ["SitDown","SitDown","SitDown","Relax","stand"];
  _x playActionNow _anim;
  _x addEventHandler ["Hit",{(_this select 0) enableSimulation true; (_this select 0) enableAI "ANIM";_x switchmove "";}];
  true 
} count _units; 

// TRIGGER!
waitUntil {behaviour leader _grp == "COMBAT" || {!alive leader _grp}};
_grp setCombatMode "RED";
{
  //_x switchmove "";
  _x playActionNow selectRandom ["Stand","Up","EvasiveLeft","EvasiveRight","MountOptic","MountSide","Down","Default"];
  _x enableAI "ANIM";
  if (random 1 > 0.5) then {_x suppressFor (3 + random 7);}; 
  true
} count _units; 

// end
true
