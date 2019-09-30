#include "script_component.hpp"
// Panic soldier
// version 1.41
// by nkenny

/*
    Types
    0 indoors
    1 crawl
    2 hide
      - chance for accidental weapons discharge

    // returns
    delay in seconds
*/

// init
params ["_unit"];

// near enemy + ace check
if (_unit distance (_unit findNearestEnemy _unit) < 35) exitWith {3};
if ((_unit getVariable ["ace_captives_isHandcuffed",false]) || {_unit getVariable ["ace_captives_issurrendering",false]}) exitWith {22};
//if (!(_unit checkAIFeature "PATH") || {!(_unit checkAIFeature "MOVE")}) exitWith {};

// settings
private _indoor = _unit call FUNC(indoor);

// debug
if (GVAR(debug_functions)) then {systemchat format ["%1 - %2 in panic",side _unit,name _unit];};

// indoor -- gesture
if (_indoor) exitWith {

    // action
    _unit forceSpeed 0;
    _unit playMoveNow selectRandom ["AmovPercMstpSnonWnonDnon_Scared","AmovPercMstpSnonWnonDnon_Scared2"];

    // chance action 
    _unit setUnitPos selectRandom ["MIDDLE","MIDDLE","PRONE"];

    // return
    _delay = 6 + random 4;
    _delay
};

// outdoor -- crawl
if (random 1 > (skill _unit)) exitWith {

    // action
    _unit dowatch objNull;  
    _unit setUnitPos "DOWN";
    [_unit,["FastB","FastLB","FastRB"]] call FUNC(gesture);
    
    // return 
    _delay = 6 + random 6;
    _delay
};

// outdoor -- hide

// action
_unit dowatch objNull;
[_unit,_unit getPos [100,direction _unit],55] call FUNC(hideInside);

// chance to randomly fire weapon
if ((random 1 > 0.7) && {!(primaryWeapon _unit isEqualTo "")}) then {
    _unit forceWeaponFire [(weapons _unit) select 0, selectRandom (getArray (configFile >> "CfgWeapons" >> ((weapons _unit) select 0) >> "modes"))];
};

// chance to randomly wave
if (random 1 > 0.4) then {
    [_unit,["GestureCover"]] call FUNC(gesture);
};

// return
_delay = 12 + random 12;
_delay