#include "script_component.hpp"
// Event Callback Wrapper
// version 1.01
// by jokoho482
params ["_eventName", "_eventParameter"];

[_eventName, _eventParameter] spawn {
    [{
         _this call CBA_fnc_localEvent;
    }, _this] call CBA_fnc_directCall;
};
