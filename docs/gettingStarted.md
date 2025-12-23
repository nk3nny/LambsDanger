# LAMBS Danger FSM
This is the knowledge hub of the *LAMBS Danger FSM* mod for ARMA 3. The mod is fully open source and happily accepts contributions.

Features and modules are described in appropriate pages.  

## Design
The mod contains enhancements to AI intelligence by writing new features to the danger.fsm (finite state machine). The FSM triggers when an AI is in combat mode.

### Goals
1. Make buildings part of the AI tactical landscape
2. Improve AI feedback and intelligence by adding distinct AI states
3. Seamless integration with vanilla, ACE3 and modded assets

### Design philosophy
A better AI is one which performs tactically sound actions, in a manner which is consistent, predictable and clearly communicated.

Improvements to the AI are made with the explicit intention of adding distinct *states* or modes of action. An AI state is a type of behavior which is understood by onlookers and tactically sound from the perspective of the simulator. Each change of state comes about based on the situation.

The best or fastest action is not always appropriate.  AI behavior becomes less robotic if approached from a philosophy of *fuzzy predictability*. This is a way of simulating human behavior within the limits of ARMA 3. Predictability comes from states may be interpreted by observing animations, stance changes, and patterns of movement. Fuzziness come from the depth of the simulation and flow of knowledge present in AI decision making processes.

# Features
* AI will move inside buildings
* Perform suppressive fire (Vehicles will dismantle buildings)
* Panic, with special effects
* React, even when exact enemy position is unknown
* React by hiding in the presence of powerful vehicles when without equipment to deal with it
* Check dead bodies (Rearms if possible)
* Tanks will react by rotating towards threats
* Improved civilian reactions, hiding in buildings and checking dead bodies
* Dynamic Artillery system
* Custom waypoints for specific AI behaviour

## Installation
The mod runs automatically for all factions, including RHS and CUP. To double check that the mod is runing, enable one of the debug variables.

### Requirements
LAMBS danger fsm requires the latest version of [CBA](https://github.com/CBATeam/CBA_A3).


## Compatibility
The mod is fully compatible with [ACE3](https://github.com/acemod/ACE3). This version requires CBA.

## Development
Check the [GitHub](https://github.com/nk3nney/LambsDanger) for development variables to toggle or tweak gameplay features.

Join our Discord for news, discussions, feedback and happy times.

## Releases
The latest official release is available from the [STEAM WORKSHOP](https://steamcommunity.com/sharedfiles/filedetails/?id=1858075458).
