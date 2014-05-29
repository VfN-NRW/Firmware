
This is just a piece of alpha software, DO NOT USE it for anything except testing purposes.

# How to Build

`git clone https://github.com/FF-NRW/Firmware.git`  
`git submodule update --init`  
`./1compile.sh`  

# Configuration
Autoupdate firmware-distribution

nightly = will be build each night if anything is change. This is living on the edge (risky)

stage1 = first rollout of the firmware. this should be running quite well

stage2 = if everything worked fine in stage1, stage2 is released

stable = stable firmware that has prooved running good (this is default)

rocksolid = a conservative firmware release - the most stable. is only release if it is realy needed. use this if you plan to build the router INTO a wall.

