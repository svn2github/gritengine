-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `classes.lua`

material `Pin` {
    diffuseMap=`Pin.dds`,
    specularMask=.08,
    glossMask=.5,
}

material `Ball` {
    diffuseMap=`Ball.dds`,
    specularMask=.08,
    glossMask=.75,
}

-- TODO: This should be cleaned up, I think there is no need for extends() in this case.
class `Deck` (extends(ProcPileClass) {
    spawnObjects = function(persistent, spawn)
        local rows = persistent.rows
        local space = persistent.space
        local spacex = space
        local spacey = space * .8645
        for y=1,rows do
                for x=-y+1,y,2 do
                        spawn(persistent.pinClass, vector3(x*spacex/2, (y-1)*spacey, class_get(persistent.pinClass).placementZOffset), {})
                end
        end
    end;
}) {
    renderingDistance=100;
    pinClass = `Pin`;
    rows = 4;
    space = .3;
}
