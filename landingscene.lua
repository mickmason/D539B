local composer = require('composer')
local scene = composer.newScene()



-- scene:create()
function scene:create(event)
    -- ** Landing page group ** --
    local sceneGroup = self.view
    -- Display objects --
    local landingPageGroup = display.newGroup() 
    sceneGroup:insert(landingPageGroups)
    landingPageGroup.width = pageWidth --5px padding on either side
    landingPageGroup.height = displayHeight - 30 --30px padding on the top of the game area
    
    --Top scores table
    local topScoresGroup = display.newGroup() 
    landingPageGroup:insert(topScoresGroup)
    
    local topScoresBg = display.newRect(displayCenter.x, 0, displayWidth*0.4, 400)
    topScoresBg.y = displayCenter.y - topScoresBg.height*0.5 + pagePadding.top
    topScoresBg:setFillColor(0.3, 0.3, 0.3)
    
    --Play button
    local playBttnGroup = display.newGroup()
    landingPageGroup:insert(playBttnGroup)
    local playBttn = display.newRect(displayCenter.x, 0, topScoresBg.width, 35)
    
    playBttn:setFillColor(0.3, 0.3, 0.3)
    playBttnText = display.newText({parent=playBttnGroup, text='Play!', font=gameBaseFont, fontSize=22, height=35, align='center', width=playBttn.width})
    
    
        playBttn.x, playBttn.y = displayCenter.x, topScoresBg.y + topScoresBg*0.5 + 20
        playBttnText.x, playBttnText.y = playBttn.x, playBttn.y
    
    -- Data --
    local topScores, err = loadScoresData()
    if (err) then
        print(err)
    end
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    if (phase = 'will') then
        
    end
end
