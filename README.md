
## This is just a piece of alpha software, DO NOT USE it without advice for anything except testing purposes.

# Bugtracker

Do report EVERY bug you find!

Bugtracker: http://bug.freifunk.net/projects/fff-nrw/issues/new


# How to Build

Deps:
apt-get install build-essential libncurses-dev libncurses5-dev zlib1g-dev gawk qemu-utils

`git clone https://github.com/FF-NRW/Firmware.git`  
`cd Firmware`  
`git checkout stable`  
`git submodule update --init`  
`./1compile.sh && ./2extractIB.sh && ./3makeImage.sh`  

to add maintainkeys (for ssh) add "with_FFNRW_maintainkeys" as first parameter for the 3rd script:

`./1compile.sh && ./2extractIB.sh && ./3makeImage.sh with_FFNRW_maintainkeys`  

# Configuration
Autoupdate firmware-distribution

nightly = will be build each night if anything is change. This is living on the edge (risky)

stage1 = first rollout of the firmware. this should be running quite well

stage2 = if everything worked fine in stage1, stage2 is released

stable = stable firmware that has prooved running good (this is default)

rocksolid = a conservative firmware release - the most stable. is only released if its really needed. use this if you plan to include the router INTO walls.

