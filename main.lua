require "CiderDebugger";
local globals = require('globals')
local composer = require('composer')

-- main.lua --
local options = {
    effect = "fade",
    time = 500,
    params = {
        someKey = "someValue",
        someOtherKey = 10
    }
}


local function onSystemEvent( event )
    print( "System event name and type: " .. event.name, event.type )
end

Runtime:addEventListener( "system", onSystemEvent )

composer.gotoScene('landingscene', options)


