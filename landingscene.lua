local composer = require('composer')
local scene = composer.newScene()


-- scene:create()
function scene:create(event)
    -- ** Landing page group ** --
    local sceneGroup = self.view
    -- Display objects --
        
    -- an array of all display object groups - used in scene:destroy() to remove them    
    displayObjectGroups = {}
    
    --landing page wrapper group
    local landingPageGroup = display.newGroup() 
    sceneGroup:insert(landingPageGroup)
    landingPageGroup.width = pageWidth --5px padding on either side
    landingPageGroup.height = displayHeight - 30 --30px padding on the top of the game area
    
    table.insert(displayObjects, landingPageGroup)

    --Top scores table group
    local topScoresGroup = display.newGroup() 
    landingPageGroup:insert(topScoresGroup)
    
    table.insert(displayObjects, topScoresGroup)    
    
    local topScoresBg = display.newRect(displayCenter.x, 0, displayWidth*0.4, 0)
    topScoresBg.y = displayCenter.y - topScoresBg.height*0.5 + pagePadding.top
    topScoresBg:setFillColor(0.3, 0.3, 0.3)
    
    --Play button group
    local playBttnGroup = display.newGroup()
    landingPageGroup:insert(playBttnGroup)
    
    table.insert(displayObjects, landingPageGroup)    
    
    local playBttn = display.newRect(displayCenter.x, 0, topScoresBg.width, 35)
    playBttn:setFillColor(0.3, 0.3, 0.3)
    playBttnGroup:insert(playBttn)
    
    playBttnText = display.newText({parent=playBttnGroup, text='Play!', font=gameBaseFont, fontSize=22, height=35, align='center', width=playBttn.width})
    
    -- top scores data - player data
    player = {
        username = 'michael__'
    }
    local playerData = nil
    local gameScoresData = {
        userScores = {
        }
    }     
    -- Data and objects to show it --
    playerData, dataError = loadScoresData()
    if (dataError) then
            print(dataError)
            topScoresTxt = display.newText({parent=topScoresGroup, text='Sorry there was an error'..err, font=gameBaseFont, fontSize=22, align='left', width=topScores.width, height=200})
            topScoresBg.height = topScoresTxt.height +20
    else 
        local scoresText = {}
        for i in ipairs(gameScoresData) do
            local scoresText[i] = display.newText({parent=topScoresGroup, text=player.username..'\t'..gameScoresData[i], font=gameBaseFont, fontSize=16, align='left', width=topScores.width, height=20})
            topScoresBg.height = topScoresBg.height + scoresText[i].height
        end
    end     
    
 
end

--scene:show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    if (phase = 'will') then
        playerData, dataError = loadScoresData()
        if (dataError) then
            topScoresTxt.y = topScoresBg.y
            playBttn.isVisible, playBttnText.isVisible = false, false
        else 
            for i in ipairs(scoresText) do
                scoresText[i].x,scoresText[i].y = topScoresBg.x, topScoresBg.y + (topScoresBg.height * 0.5)+ (scoresText.height * #scoresText)
            end
            playBttn.x, playBttn.y = displayCenter.x, topScoresBg.y + topScoresBg*0.5 + 20
            playBttnText.x, playBttnText.y = playBttn.x, playBttn.y
        end   
    elseif (phase == 'did') then
        if (not dataError) then
            function playBttnTapListener(event) 
                local options = {
                    effect = 'fade',
                    time = 500,
                    params = {
                        scoresData = gameScoresData
                    }
                }
                composer.goToScene('gamescene', options)
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
        if (phase = 'will') then
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
