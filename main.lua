require "CiderDebugger";
globals = require('globals')
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

composer.gotoScene('landingscene', options)


