#include "script_component.hpp"
// Unit enters CQB mode 
// version 2.0
// by nkenny

/*
    Adapted from taskCQB
  NB NB NB -- Unused as of 1.4
*/

// FUNCTIONS

// find buildings
_fn_find = {
  _buildings = nearestobjects [getpos (leader _grp),["house","strategic","ruins"],_range,true];
  _buildings = _buildings select {count (_x buildingPos -1) > 0};
  _buildings = _buildings select {count (_x getVariable ["LAMBS_CQB_cleared_" + str (side _grp),[0,0]]) > 0}; 
  if (count _buildings > 0) exitWith {_buildings select 0};
  ObjNull
}; 

// check for enemies
_fn_enemy = {
  private _pos = if (isNull _buildings) then {getpos leader _grp} else {getpos _buildings};
  _enemy = (leader _grp) findNearestEnemy _pos;
  if (isNull _enemy || {_pos distance2d _enemy < 25}) exitWith {_enemy};
  leader _grp doSuppressiveFire _enemy; 
  ObjNull
}; 

// compile actions
_fn_act = {
  // deal with close enemy
  if (!isNull _enemy) exitWith {
    
    // debug 
    if (GVAR(debug_functions)) then {
      systemchat "danger.fnc taskCQB: RUSH ENEMY!";
      _veh = createVehicle ["Sign_Arrow_Large_F",getposATL _enemy,[],0,"CAN_COLLIDE"];
    }; 
    
    // posture
    doStop units _grp; 
    leader _grp playAction selectRandom ["gestureAttack","gestureGo","gestureGoB"];
    
    // location
    _buildingPos = ((nearestBuilding _enemy) buildingPos -1) select {_x distance _enemy < 5};
    _buildingPos pushBack getPosATL _enemy;
    
    // act
      {_x doMove selectRandom _buildingPos;_x doWatch _enemy;true} count units _grp; 
  };
    
  // clear and check buildings
  _buildingPos = _buildings getVariable ["LAMBS_CQB_cleared_" + str (side _grp),(_buildings buildingPos -1) select {lineIntersects [AGLToASL _x, (AGLToASL _x) vectorAdd [0,0,10]]}];
  //_bp = _b getVariable ["nk_CQB_cleared",(_b buildingPos -1)];
  {
    // the assault
    if ((count _buildingPos > 0) && {unitReady _x}) then {
        _x setUnitPos "UP";
        _x doMove ((_buildingPos select 0) vectorAdd [0.5 - random 1,0.5 - random 1,0]);

    // debug
    if (GVAR(debug_functions)) then {
            _veh = createVehicle ["Sign_Arrow_Large_Blue_F",_buildingPos select 0,[],0,"CAN_COLLIDE"];
    };

    // Update building list when soldiers are close -- random chance to update regardless as bugfix
    if (_x distance (_buildingPos select 0) < 30 || {(leader _grp isEqualTo _x) && {random 1 > 0.5}}) then {
              _buildingPos deleteAt 0;
    } else {
              // teleport -- units sometime gets stuck due to Arma buildings
              if ((_unit call FUNC(indoor)) && {_x distance (_buildingPos select 0) > 45} && {random 1 > 0.6}) then {
                  _x setVehiclePosition [getPos _x, [], 3.5];
                };
            };
    } else {
      
      // visualisation -- unit is either busy or too far to be effective 
      _x setUnitPos "MIDDLE";
      
      // Unit is ready and outside -- try suppressive fire 
      if (unitReady _x && {!(lineIntersects [eyePos _x, (eyePos _x) vectorAdd [0,0,10]])}) then {
                _x doSuppressiveFire _buildings;
                _x doFollow leader _grp;
            };
        };
      true
  } count units _grp;

  // update variable 
  _buildings setVariable ["LAMBS_CQB_cleared_" + str (side _grp),_buildingPos];
};

// init
private _grp = param [0]; 
private _range = param [1,GVAR(CQB_range)];
private _cycle = param [2,21]; 

// sort grp
if (!local _grp) exitWith {};
_grp = [_grp] call {if (typeName _grp == "OBJECT") exitWith {group _grp};_grp}; 

// variable -- script should only run once!
if (_grp getVariable ["inCQB",false]) exitWith {};
_grp setVariable ["inCQB",true]; 

// store group settings
_speed = speedMode _grp;
_formation = formation _grp; 

// set assault mode
_grp setSpeedMode "FULL";
_grp setFormation "FILE";
_grp enableAttack false;
_grp allowFleeing 0;

// set unit stances
{
  _x disableAI "AUTOCOMBAT";
  _x disableAI "SUPPRESSION";
  _x enableIRLasers true;
  true 
} count units _grp;

// loop
while {{alive _x} count units _grp > 0} do {
  // performance
  waitUntil {sleep 1; simulationenabled leader _grp}; 
 
  // find building
  _buildings = call _fn_find;
  
  // find enemy
  _enemy = call _fn_enemy;
  
  // act! 
  if (isNull _buildings && {isNull _enemy}) exitWith {}; 
  call _fn_act;
  
  // wait
  sleep _cycle;
  if (GVAR(debug_functions)) then {systemchat format ["danger.fnc taskCQB: (team: %1) (units: %2) (enemies: %3)",groupID _grp,count units _grp,!isNull _enemy];};
};

// reset variable
_grp setVariable ["inCQB",false]; 

// reset modes
_grp setSpeedMode _speed;
_grp setFormation _formation;
_grp enableAttack true;

// reset stances
{
    _x enableAI "AUTOCOMBAT";
  _x enableAI "SUPPRESSION";
    _x moveTo getpos leader _grp; 
    _x setUnitPos "AUTO";
    _x doFollow leader _grp;
    true
} count units _grp;

// end 
true 
