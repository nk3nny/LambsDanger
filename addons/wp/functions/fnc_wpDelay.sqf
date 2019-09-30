#include "script_component.hpp"
// Delays triggering WP until group close 
// version 1.0
// by nkenny 

/*
	Arguments
		0, Group				[Group]
		1, Destination 			[array, object]
		2, Distance threshold 	[Number]

	Returns 
		true -- reached or dead! 

*/

// init 
private _grp = param [0];
private _pos = param [1]; 
private _threshold = param [2]; 

// return
(leader _grp distance _pos < _threshold) || {{alive _x} count units _grp < 1}
