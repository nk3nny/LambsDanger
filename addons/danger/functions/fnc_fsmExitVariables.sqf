#include "script_component.hpp"
// Exit variables -- returns whether or not FSM should exit
// version 1.0
// nkenny

// check
fleeing _this
|| {(_this getVariable ["ACE_isUnconscious",false])}
|| {_this getVariable [QGVAR(disableAI),false]}
|| {isplayer leader _this && {_this getVariable [QGVAR(disableAIPlayerGroup),false]}}
