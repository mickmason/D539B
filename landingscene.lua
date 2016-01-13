------------------------------
-- ** Landing page scene ** --
------------------------------

local globals = require("globals")
local composer = require('composer')

-- New scene
local scene = composer.newScene()

-- Scene-wide objects and functions
-- an array of all display object groups - used in scene:destroy() to remove them    
local displayObjectGroups = {}
-- global dimensions
local dims = globals.dimensions
-- global functions
local funcs = globals.functions

player = {
    username = 'michael__'
}
-- player and game scores data
local playerData = nil
local userScoresData = {
        userScores = nil
}     
-- Data error flag
local dataError

-- Will be display objects 
local scoresText = {}

-- scene:create()
function scene:create(event)
    -- ** Landing page group ** --
    local sceneGroup = self.view
    -- Display objects --

    --landing page wrapper group
    local landingPageGroup = display.newGroup() 
    sceneGroup:insert(landingPageGroup)
    
    table.insert(displayObjectGroups, landingPageGroup)
    
    landingPageGroup.width = pageWidth --5px padding on either side
    landingPageGroup.height = dims.displayHeight - dims.pagePadding.top --30px padding on the top of the game area
    
    table.insert(displayObjectGroups, landingPageGroup)

    --Top scores table group
    local topScoresGroup = display.newGroup() 
    landingPageGroup:insert(topScoresGroup)
    
    table.insert(displayObjectGroups, topScoresGroup)    
    
    local topScoresBg = display.newRect(dims.displayCenter.x, 0, dims.displayWidth*0.4, 0)
    topScoresBg.y = dims.displayCenter.y - topScoresBg.height*0.5 + dims.pagePadding.top
    topScoresBg:setFillColor(0.3, 0.3, 0.3)
    
    --Play button group
    local playBttnGroup = display.newGroup()
    landingPageGroup:insert(playBttnGroup)
    
    table.insert(displayObjectGroups, landingPageGroup)    
    
    local playBttn = display.newRect(dims.displayCenter.x, 0, topScoresBg.width, 35)
    playBttn:setFillColor(0.3, 0.3, 0.3)
    playBttnGroup:insert(playBttn)
    
    playBttnText = display.newText({parent=playBttnGroup, text='Play!', font=globals.fonts.gameBaseFont, fontSize=22, height=35, align='center', width=playBttn.width})
    

    -- Data and objects to show it --
    playerData, dataError = funcs.readJsonFile('player_data/player_data.json')
    if (dataError) then
            print(dataError)
            topScoresTxt = display.newText({parent=topScoresGroup, text='Sorry there was an error'..err, font=globals.fonts.gameBaseFont, fontSize=22, align='left', width=topScoresBg.width, height=200})
            topScoresBg.height = topScoresTxt.height +20
    else 
        userScoresData =  funcs.loadScoresData(playerData, player.username)

        for i in ipairs(userScoresData) do
            scoresText[i] = display.newText({parent=topScoresGroup, text=player.username..'\t'..userScoresData[i], font=globals.fonts.gameBaseFont, fontSize=16, align='left', width=topScoresBg.width, height=20})
            topScoresBg.height = topScoresBg.height + scoresText[i].height
        end
    end      
end

--scene:show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    if (phase == 'will') then
--        playerData, dataError = loadScoresData()

        if (event.params) then
            --print('Event params '..event.params.someKey)
        end

        if (dataError) then
            topScoresTxt.y = topScoresBg.y
            playBttn.isVisible, playBttnText.isVisible = false, false
        else 
            for i in ipairs(scoresText) do
                scoresText[i].x,scoresText[i].y = topScoresBg.x, topScoresBg.y + (topScoresBg.height * 0.5)+ (scoresText.height * #scoresText)
            end
            playBttn.x, playBttn.y = dims.displayCenter.x, topScoresBg.y + topScoresBg*0.5 + 20
            playBttnText.x, playBttnText.y = playBttn.x, playBttn.y
        end   
    elseif (phase == 'did') then
        if (not dataError) then
            function playBttnTapListener(e) 
                local options = {
                    effect = 'fade',
                    time = 500,
                    params = {
                        scoresData = userScoresData
                    }
                }
                composer.gotoScene('gamescene', options)
            end
            playBttn.tap = playBttnTapListener
            playBttn:addEventListener('tap', playBttn)
        end
    end
end --end scene:show()

-- scene:hide()
function scene:hide(event)
        local sceneGroup = self.view
        local phase = event.phase
        if (phase == 'will') then
            playBttn:removeEventListener('tap', playBttnTapListener)
        end
end--end scene:hide()

-- scene:destroy
function scene:destroy()
    local sceneGroup = self.view
    for i, group in ipairs(displayObjectGroups) do
        display.remove(group)
    end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene

