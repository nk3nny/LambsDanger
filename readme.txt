# LAMBS Danger
Expansion of vanilla Danger.fsm. Added are features which extend the enemy response and reaction to fire. 

The overall goal is to make buildings part of the AI's available terrain. The AI will dynamically enter and clear buildings holding enemy soldiers. The nature of the the danger.fsm does not make these features a replacement for dedicated scripts however. 

### Features
 * AI will move inside buildings
 * Perform suppressive fire (Vehicles will dismantle buildings)
 * Panic, with special effects 
 * React, even when exact enemy position is unknown 
 * React by hiding in the presence of powerful vehicles when without equipment to deal with it
 * Check dead bodies (Rearms if possible)
 * Tanks will react by rotating towards threats  
 * Improved civilian reactions, hiding in buildings and checking dead bodies 
 
### Variables 
- lambs_danger_CQB_range, Range which units consider themselves in CQC (Default 60)
- lambs_danger_CQB_formations, Formations which enable CQC routines (Default ["FILE","DIAMOND"]), 
- lambs_danger_panic_chance, Chance of panic state/animation. 1 out of this number.  (i.e., 1 out of 20 is 5%)
- lambs_danger_debug_FSM, FSM level debug messages (Default False)
- lambs_danger_debug_functions, Function level debug messages (Default False)
- lambs_danger_debug_FSMciv, FSM level debug messages for civilian settings (Default False)

### Special note
 - The 'FILE' or 'DIAMOND/DELTA' formations enable a special CQB mode. The AI will (in a reactive fashion) clear out buildings methodically in the vicinity of enemy forces. 
 - To disable many of the mobility features set the group to '_group enableAttack false_'[Link] (https://community.bistudio.com/wiki/enableAttack) 