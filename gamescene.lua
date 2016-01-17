----------------------
-- ** Game scene ** --
----------------------

local globals = require("globals")
animations = require("animations")
local composer = require('composer')
-- * physics envirionment * --
local physics = require "physics"
        physics.start()
        physics.setReportCollisionsInContentCoordinates(true)
        physics.setReportCollisionsInContentCoordinates( true)  
-- New scene
local scene = composer.newScene()

-- Scene-wide objects and functions
-- an array of all display object groups - used in scene:destroy() to remove them    
local displayObjectGroups = {}

-- Global variables and functions
local dims = globals.dimensions
local funcs = globals.functions
local gameFont = globals.fonts.gameBaseFont
player = {
    username = 'michael__'
}

local playerData = nil
-- ** user top scores ** --
local userScoresData = {
        userScores = nil
}

-- an array of all display object groups - used in scene:destroy() to remove them    
local displayObjectGroups = {}

--scene-wide variables
local gamePageGroup = nil
local gamePageGroup = nil
-- ** Game UI elements: start button, score, timer, life force go in here ** --
local gameUIGroup = nil
-- Score text
local score = nil
--Game timer countdown
local countdown = nil
-- Game clock timer ref
local clockTimerRef = nil
-- Lifeforce indicator
local lfIndicator = nil
local lfIndicatorBG = nil
-- Game over
local gameOver = nil
local gameOverScore = nil

--Back to home button
local backToHomeButton = nil
local backToHomeButtonText = nil

-- ** Game display objects, ships, laser shots **--
local gameShips, gameShipsErr = nil
--player ship
local playerShip = nil
--Alien ships - use this array to track ships
local attackersNames = nil 
-- Alien ship display objects
local attackers = {}
-- A count of attackers, used to provide a unique index for each ship
local attackersCount = 0

-- * Some timer references for alien behaviours * -- 
local alienShooterTimerRef = nil
local alienMovementTimerRef = nil

--** scene-wide functions **--
-- Game lasts 1 minute
local gameLength = 1 * 60 -- this could be set to different values for other rounds
--countdown function
function timerCount() 
    gameLength = gameLength - 1
    local mins = math.floor(gameLength/60)
    local secs = gameLength % 60
    countdown.text = string.format( "%02d:%02d", mins, secs )    
end

--Function which counts the game in 
local countInSeconds = 3
local countInText = nil
local startText = nil
function countIn()
    countInText.text = string.format( "%02d:%02d", countInSeconds)
    countInSeconds = countInSeconds -1
    if (countInSeconds == 0) then
        return true
    end
end

function startTimer(timerFunction, duration) 
    return timer.performWithDelay(1000, timerFunction, duration)
end
function pauseTimer(timerRef) 
    if (timerRef ~= nil) then timer.pause(timerRef) end
end
function resumeTimer(timerRef) 
    if (timerRef ~= nil) then timer.resume(timerRef) end
end

--** Game functions **--
--function to decrement the life force indicator
function decrementLfIndicator(decUnit)
    lfIndicator.width = lfIndicator.width - decUnit
    if (lfIndicator.width <= lfIndicator.initialWidth*0.5) then
        lfIndicator:setFillColor(1, 0.388, 0.278)
    elseif (lfIndicator.width <= lfIndicator.initialWidth*0.3333) then
        lfIndicator:setFillColor(1, 0, 0)
    end
end

--increment the score - takes an alien ships and gets its hit score
function incrementScore(hitShip)
    score.score = score.score + hitShip.killScore
    score.text = score.score
end

-- ** Game start, stop, pause ** --

function startGame() 
    print('Start game')
    alienMovementTimerRef = timer.performWithDelay(1000, moveAliens, -1)  
    --alien shots timer
    alienShooterTimerRef = timer.performWithDelay(600, alienFireTheLaser, -1) 
    clockTimerRef  = startTimer(timerCount, gameLength)
end

function pauseGame()
    timer.pause(alienMovementTimerRef)
    --alien shots timer
    timer.pause(alienShooterTimerRef)

    pauseTimer()
end
function endGame()
    timer.cancel(alienMovementTimerRef)
    --alien shots timer
    timer.cancel(alienShooterTimerRef)
    timer.cancel(clockTimerRef)
    gameOverScore.text = 'Score: '..score.text
    gameOverScore.isVisible = true
    gameOver.isVisible = true
    userScoresData = funcs.updateScoresData(userScoresData, score.text)      
    backToHomeButton.isVisible = true
    backToHomeButtonText.isVisible = true
    backToHomeButtonText:addEventListener('tap', function() 
        --print(userScoresData[1])
        local options = {
                    effect = 'fade',
                    time = 500,
                    params = {
                        scoresData = userScoresData
                    }
        }
        
        composer.gotoScene('landingscene', options)
    end)    

    --funcs.writeJsonFile('player_data/player_data.json', topScores)
end --endGame()


--**  Game Event Handler functions ** --
function backToHomeButtonTap() 
    --do paging back to landing page
end

--***Player laser shot collision handler **--
function laserOnCollision(self,event)
    if (event.phase == 'began') then
        print('Laser collision began with '..event.other.name)
        print('Self x,y '..self.x..','..self.y)
        transition.cancel(self.transitionId)                
        local alienShip = event.other
        alienShip.hitCount = alienShip.hitCount + 1
        local expl = nil
        if (alienShip.hitCount == alienShip.shipMaxHits) then
            print('Kill alien '..alienShip.name)
            alienShip.isDead = true
            --create an explosion animation
            expl = animations.make_dead_explosion()
            expl:addEventListener('sprite', animations.sprite_listener)
            expl.x,expl.y = self.x,self.y 
            expl.isVisible = true
            expl:play()
            incrementScore(alienShip)
            local wasMaxLeft = false
            if (alienShip.isMaxLeft) then
                wasMaxLeft = true
            end
            if (alienShip.isMaxRight) then
                wasMaxRight = true
            end
            print('Remove ship: '..table.remove(attackersNames, table.indexOf(attackersNames, alienShip.name)))
            -- need this for alien movement across the screen - which are the right and leftmost ships
            if (wasMaxLeft or wasMaxRight) then
                local smallestX = 0
                local biggestX = 0
                for i=1, #attackersNames do
                    if (attackers[attackersNames[i]].x < smallestX) then
                        smallestX = attackers[attackersNames[i]].x
                        attackers[attackersNames[i]].isMaxLeft = true
                    end
                    if (attackers[attackersNames[i]].x > biggestX) then
                        biggestX = attackers[attackersNames[i]].x
                        attackers[attackersNames[i]].isMaxRight = true
                    end
                end
            end
            display.remove(alienShip)
            if (#attackersNames == 0) then
                -- Game over
                endGame()
            end
        else
            --create an explosion animation
            expl = animations.make_medium_explosion()
            expl:addEventListener('sprite', animations.sprite_listener)
            expl.x,expl.y = self.x,self.y 
            expl.isVisible = true
            expl:play()
        end 

        display.remove(self)
        return true
    elseif (event.phase == 'ended') then
        print('Laser collision ended  '..self.name)
        transition.cancel(self.transitionId)
        return true
    end
end -- end laser on collision

-- creates a laser shot. Takes and idx to create a unique name
function createLaserShot() 
    local playerLaserShot = display.newImage(gameGroup, "assets/"..gameShips.playerShip.laserShot.image_path)
    playerLaserShot.x = playerShip.x
    playerLaserShot.y = playerShip.y - playerShip.height* 0.5  - playerLaserShot.height * 0.5 - 10
    physics.addBody(playerLaserShot, {shape=gameShips.playerShip.laserShot.shape, filter= gameShips.playerShip.laserShot.categoryFilter})
    playerLaserShot.gravityScale = 0
    playerLaserShot.type = "Laser shot"
    playerLaserShot.name = "Laser shot"
    playerLaserShot.isVisible = false
    playerLaserShot.collision = laserOnCollision
    playerLaserShot:addEventListener('collision', playerLaserShot)
    return playerLaserShot
end
--Function which fires the player laser - player ship ontap
function fireTheLaser()
    if (playerShip) then
        local shot = createLaserShot()
        shot.x = playerShip.x
        shot.isVisible = true
        local params = {
            time = 800,
            transition = easing.inOutQuad,
            onStart = function() 
    --            print('Start shot x: '..shot.x)
    --            print('Start shot y: '..shot.y)
            end,
            onComplete = function() 
    --            print('End shot x: '..shot.x)
    --            print('End shot y: '..shot.y)
                display.remove(shot)
            end,
            x=shot.x, 
            y=-1000
        }
        shot.transitionId =  transition.to(shot, params)        
    else 
        return false
    end
end -- fireTheLaser()

--Player taps ship
function playerTapHandler(self,event)
        fireTheLaser()
end

--player touch handler
function playerTouchHandler(self,event) 
    if (event.phase == 'began') then
        return true
    end
    if (event.phase == 'moved') then
--        print("Move on "..self.name)
        playerShip.x = event.x
--        laserShot.x = playerShip.x
        return true
    end
    if (event.phase == 'ended') then
        return true
    end 
    if (event.phase == "cancelled") then
        print('The jobs off boys')
        return false
    end
end--player touch handler


-- Alien laser shot collision handler
function alienLaserOnCollision(self, event)
    print('Collision with player ship at: '..self.x, self.y)
        local shot = self
        transition.cancel(shot.transitionId)
        display.remove(shot)
        local player = event.other
        player.ki = player.ki - shot.laserPower
        print(shot.lfDecrementUnit)
        decrementLfIndicator(shot.lfDecrementUnit)
        local expl = nil
        if (player.ki == 0) then
            print("El Player es muerta")
            decrementLfIndicator(lfIndicator.width-1)
            expl = animations.make_dead_explosion()

            expl:addEventListener('sprite', animations.sprite_listener)

            expl.x,expl.y = shot.x,shot.y 
            expl.isVisible = true
            expl:play()
            display.remove(playerShip)
            -- Game over
            endGame()
        else
            expl = animations.make_medium_explosion()
            expl:addEventListener('sprite', animations.sprite_listener)
            expl.x,expl.y = shot.x,shot.y 
            expl.isVisible = true
            expl:play()
        end 
end 

-- alien laser shoots player
function alienFireTheLaser() 
        local ship = nil
        if (#attackersNames > 0) then 
            while (ship == nil) do
                ship = attackers[attackersNames[math.random(1,#attackersNames)]]
            end             
            print(ship.name)
            local alienShot = display.newImage(gameGroup, "assets/"..gameShips.alienShips.alienLaserShot.image_path)
            ship:toFront()
            alienShot.x,alienShot.y = ship.x, ship.y+ship.height
            physics.addBody(alienShot, {shape=gameShips.alienShips.alienLaserShot.shape, filter=gameShips.alienShips.alienLaserShot.categoryFilter})
            alienShot.gravityScale = 0
            alienShot.isSensor = gameShips.alienShips.alienLaserShot.isSensor
            alienShot.bodyType = gameShips.alienShips.alienLaserShot.bodyType
            alienShot.type = "AlienLaserShot"
            alienShot.name = "Alien Laser shot"
            alienShot.laserPower = gameShips.alienShips.alienLaserShot.laserPower
            --The life force indicator decrememnt unit is used to decrement the life force indicator when the player ship is hit
            alienShot.lfDecrementUnit = (lfIndicator.initialWidth/playerShip.startKi) * alienShot.laserPower               
            alienShot.collision = alienLaserOnCollision
            alienShot:addEventListener('collision', alienShot)
            local params = {
                time = 600,
                transition = easing.inOutQuad,
                onStart = function()
    --                print('Start shot x: '..shot.x)
    --                print('Start shot y: '..shot.y)
                end,
                onComplete = function()
    --                print('End shot x: '..shot.x)
    --                print('End shot y: '..shot.y)
                    display.remove(alienShot)
                end,
                x=alienShot.x, 
                y=1000
            }
                alienShot.transitionId = transition.to(alienShot, params)
            else 
                timer.cancel(alienShooterTimerRef)
                
            end
end

-- * Move the aliens across the screen * --
local aliensMovementTransitionID = nil
--Should the move be up or down on the y axis
local    yUp = false
local moveRtl = false
function moveAliens() 
    --how far left and right they can go
    local maxLeft = 10
    local maxRight = dims.displayWidth - 10
    --a single move on the y axis
    local yMove = 5
    --a single move on the x axis
    local xMove = dims.displayWidth / 31

    if (moveRtl == true) then
        if (yUp ==  false) then
            for i=1, #attackersNames do
                attackers[attackersNames[i]].x, attackers[attackersNames[i]].y = attackers[attackersNames[i]].x-xMove, attackers[attackersNames[i]].y+yMove 
                if (attackers[attackersNames[i]].isMaxLeft) then
                    if (attackers[attackersNames[i]].x - (attackers[attackersNames[i]].width*0.5) - xMove < maxLeft) then
                        moveRtl = false
                    end
                end
            end
            yUp = true
        else
            for i=1, #attackersNames do
                attackers[attackersNames[i]].x, attackers[attackersNames[i]].y = attackers[attackersNames[i]].x-xMove, attackers[attackersNames[i]].y-yMove
                if (attackers[attackersNames[i]].isMaxLeft) then
                    print(attackers[attackersNames[i]].name..' is max left.')
                    if (attackers[attackersNames[i]].x - (attackers[attackersNames[i]].width*0.5) - xMove < maxLeft) then
                        moveRtl = false
                    end
                end
            end            
            yUp = false
        end    
    else
        if (yUp ==  false) then
            for i=1, #attackersNames do
                attackers[attackersNames[i]].x, attackers[attackersNames[i]].y = attackers[attackersNames[i]].x+xMove, attackers[attackersNames[i]].y+yMove 
                if (attackers[attackersNames[i]].isMaxRight) then
                    if (attackers[attackersNames[i]].x + (attackers[attackersNames[i]].width*0.5) + xMove > maxRight) then
                        moveRtl = true
                    end
                end
            end
            yUp = true
        else
            for i=1, #attackersNames do
                attackers[attackersNames[i]].x, attackers[attackersNames[i]].y = attackers[attackersNames[i]].x+xMove, attackers[attackersNames[i]].y-yMove
                if (attackers[attackersNames[i]].isMaxRight) then
                    if (attackers[attackersNames[i]].x + (attackers[attackersNames[i]].width*0.5) + xMove > maxRight) then
                        moveRtl = true
                    end
                end
            end         
            if (moveRtl) then
                for i=1, #attackersNames do
                    attackers[attackersNames[i]].y = attackers[attackersNames[i]].y +20
                end
            end
            yUp = false
        end   
    end 
end

--** Scene lifecycle functions ** --

-- scene:create()
function scene:create(event)
    local sceneGroup = self.view
    local params = event.params
  
    -- ** Create groups ** --
    -- Group for the whole page
    gamePageGroup = display.newGroup()
    sceneGroup:insert(gamePageGroup)
    -- max widths and game boundaries --
    gamePageGroup.width = dims.displayWidth - (dims.pagePadding.right * 2) --5px padding on either side
    gamePageGroup.height = dims.displayHeight 
    gamePageGroup.maxXLeft = dims.displayCenter.x - gamePageGroup.width * 0.5 
    gamePageGroup.maxXRight = dims.displayCenter.x + gamePageGroup.width * 0.5 
    gamePageGroup.maxTop = dims.displayCenter.y - gamePageGroup.height * 0.5 
    gamePageGroup.maxBottom = dims.displayCenter.y + gamePageGroup.height * 0.5 
    
    -- Add it to the groups array
    table.insert(displayObjectGroups, gamePageGroup)
    
    -- For UI elements - score etc
    gameUIGroup = display.newGroup()
    gamePageGroup:insert(gameUIGroup)    
    --UI elements score, game timer, life force indicator, back to landing page button
    
    -- score text
    score = display.newText({parent=gameUIGroup, text='100', font=gameFont, fontSize=22, height=100, align='right', width=(dims.displayWidth*0.5)-20})
    score.anchorX, score.anchorY  = 0,0
    score.x = dims.displayWidth*0.5
    score.y = -25
    score.score = 0
    score.text = score.score
    
    -- game countin
    countInText = display.newText({parent=gameUIGroup, text='01:00', font=gameFont, fontSize=8, height=100, width=(dims.displayWidth*0.5), x=dims.displayCenter.x, y=dims.displayCenter.y})
    countInText.isVisible = false
    startText = display.newText({parent=gameUIGroup, text='01:00', font=gameFont, fontSize=8, height=100, width=(dims.displayWidth*0.5), x=dims.displayCenter.x, y=dims.displayCenter.y})
    startText:setFillColor(0.9,0.2,0.2)
    startText.isVisible = false

    --game countdown 
    countdown = display.newText({parent=gameUIGroup, text='01:00', font=gameFont, fontSize=22, height=100, align='left', width=(dims.displayWidth*0.5)})
    countdown.anchorX, countdown.anchorY  = 0,0
    countdown.y = -25
    countdown.x = 20

    -- Lifeforce indicator
    lfIndicator = display.newRect(dims.displayWidth, dims.displayHeight, dims.displayWidth*0.23, 3, 2)
    gameUIGroup:insert(lfIndicator)
    lfIndicator.x = dims.displayWidth-lfIndicator.width - 10 
    lfIndicator.initialWidth = lfIndicator.width
    lfIndicator:setFillColor(0.1,0.8,0.1)
    lfIndicator.anchorX, lfIndicator.anchorY  = 0,0
    lfIndicatorBG = display.newRect(lfIndicator.x - 1, lfIndicator.y -1, lfIndicator.width+2, lfIndicator.height+2, 2)
    gameUIGroup:insert(lfIndicatorBG)
    lfIndicatorBG.anchorX, lfIndicatorBG.anchorY = 0,0
    lfIndicatorBG:setFillColor(0.3,0.3,0.3)
    lfIndicator:toFront()

    -- Game over text
    gameOver = display.newText({parent=gameUIGroup, text='Game over', font=gameFont, fontSize=32, height=100, align='center', width=(dims.displayWidth*0.5)})
    gameOver.isVisible = false
    gameOver.x, gameOver.y = dims.displayCenter.x, dims.displayCenter.y - dims.displayHeight * 0.23
    gameOverScore = display.newText({parent=gameUIGroup, text='Score', font=gameFont, fontSize=22, height=100, align='center', width=(dims.displayWidth*0.5)})
    gameOverScore.isVisible = false
    gameOverScore.x, gameOverScore.y = dims.displayCenter.x, gameOver.y + 50

    --Back to home button
    backToHomeButton = display.newRect(gameOverScore.x, gameOverScore.y+20, dims.displayWidth*0.45, 34, 2)
    gameUIGroup:insert(lfIndicator)
    backToHomeButton:setFillColor(0.3,0.3,0.3)
    backToHomeButton.isVisible = false
    backToHomeButtonText = display.newText({parent=gameUIGroup, text='Back to home', font=gameFont, fontSize=18, height=backToHomeButton.height, align='center', width=(dims.displayWidth*0.5)})
    backToHomeButtonText.x, backToHomeButtonText.y = backToHomeButton.x, backToHomeButton.y+6
    backToHomeButtonText.isVisible = false
    backToHomeButton:toBack()    
    
    -- Add it to the groups array
    table.insert(displayObjectGroups, gameUIGroup)
    
    --game group - contains the game objects - ships, laser shots
    gameGroup = display.newGroup();
    gameGroup.width, gameGroup.height = dims.displayWidth,dims.displayHeight 
    gamePageGroup:insert(gameGroup)
    gameGroup.y = 50
    gameGroup.center = {
        x = dims.displayCenter.x,
        y = dims.displayCenter.y
    }
    
    -- Add it to the groups array
    table.insert(displayObjectGroups, gameGroup)
    
    --gameShips display obects
    gameShips, gameShipsErr = funcs.readJsonFile('ships_data/game_ships.json')
    if (gameShips) then
        
        -- Add the attackers
        attackersNames = {'bigShip', 'smallShip1', 'smallShip2'}       
        -- get the alien ships, add them to the attackers array
        for k, v in pairs(attackersNames) do
            if (v=='bigShip') then
                attackers[v] = display.newImage("assets/"..gameShips.alienShips.bigShip.image_path)
                attackers[v].name = v
                attackers[v].shipMaxHits = gameShips.alienShips.bigShip.shipMaxHits
                attackers[v].killScore = gameShips.alienShips.bigShip.killScore
                attackers[v].laserPower = gameShips.alienShips.bigShip.laserPower        
                gameGroup:insert(attackers[v])
                attackers[v].idx = attackersCount +1 
                physics.addBody(attackers[v], {shape=gameShips.alienShips.bigShip.shape})
                attackers[v].isSensor = gameShips.alienShips.bigShip.isSensor                
            elseif (v=='smallShip1') then
                attackers[v] = display.newImage("assets/"..gameShips.alienShips.smallShip1.image_path)
                attackers[v].name = v
                attackers[v].shipMaxHits = gameShips.alienShips.smallShip1.shipMaxHits
                attackers[v].killScore = gameShips.alienShips.smallShip1.killScore
                attackers[v].laserPower = gameShips.alienShips.smallShip1.laserPower
                gameGroup:insert(attackers[v])
                attackers[v].idx = attackersCount +1       
                attackers[v].isMaxLeft = true
                physics.addBody(attackers[v], {shape=gameShips.alienShips.smallShip1.shape})
                attackers[v].isSensor = gameShips.alienShips.smallShip1.isSensor                
                
            elseif (v=='smallShip2') then 
                attackers[v] = display.newImage("assets/"..gameShips.alienShips.smallShip1.image_path)
                attackers[v].name = v
                attackers[v].shipMaxHits = gameShips.alienShips.smallShip1.shipMaxHits
                attackers[v].killScore = gameShips.alienShips.smallShip1.killScore
                attackers[v].laserPower = gameShips.alienShips.smallShip1.laserPower
                gameGroup:insert(attackers[v])
                attackers[v].idx = attackersCount +1         
                attackers[v].isMaxRight = true
                physics.addBody(attackers[v], {shape=gameShips.alienShips.smallShip1.shape})
                attackers[v].isSensor = gameShips.alienShips.smallShip1.isSensor                
            end
            attackers[v].gravityScale = 0
            attackers[v].hitCount = 0
            attackersCount = attackersCount + 1
        end-- end foreach alien ship        
    elseif (gameShipsErr) then
        print(gameShipsErr)
        return true
    end -- end if gameShip data
    
    --Add the game player ship
    playerShip = display.newImage(gameGroup, "assets/"..gameShips.playerShip.image_path)
    physics.addBody(playerShip, {shape=gameShips.playerShip.shape, filter =  gameShips.playerShip.categoryFilter})
    playerShip.name = "Player ship"
    playerShip.ki = gameShips.playerShip.ki
    playerShip.startKi = playerShip.ki
--player ship physics
            physics.addBody(playerShip, {shape=gameShips.playerShip.shape, filter =  gameShips.playerShip.categoryFilter})
            playerShip.gravityScale = 0
            playerShip.isSensor = gameShips.playerShip.isSensor        

end -- scene:create()

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if (phase == 'will') then
        attackersNames = {'bigShip', 'smallShip1', 'smallShip2'} 
        -- get scores data for the user
        if (event.params.scoresData) then
            userScoresData = event.params.scoresData
            
        else     
            playerData, dataError = funcs.readJsonFile('player_data/player_data.json')
            if (dataError) then
                print(dataError)
            else 
                userScoresData = funcs.loadScoresData(playerData, player.username)
            end            
        end
        
--        if (#attackers < 3) then
--            attackersNames = {}
--            attackersNames = {'bigShip', 'smallShip1', 'smallShip2'}  
--        end
        attackersNames = {'bigShip', 'smallShip1', 'smallShip2'}  
        if (gameShips) then
            -- position alien ships
            for k, v in pairs(attackersNames) do
                if (v=='bigShip') then                
                    attackers[v].y = 0
                    attackers[v].x = gameGroup.center.x
                    attackers[v].idx = attackersCount +1 
                elseif (v=='smallShip1') then
                    attackers[v].y = 64
                    attackers[v].x = gameGroup.center.x - (gameGroup.width * 0.25)
                elseif (v=='smallShip2') then 
                    attackers[v].y = 64
                    attackers[v].x = gameGroup.center.x + (gameGroup.width * 0.25)
                end
            end -- end foreach alien ship
            
            --playership positions
            playerShip.x = dims.displayCenter.x
            playerShip.y = dims.displayHeight - playerShip.height - 50
            playerShip.name = "Player ship"
            playerShip.ki = gameShips.playerShip.ki
            playerShip.startKi = playerShip.ki            
            
        elseif (err) then
            print(err)
        end-- end if gameShips data
        --end show 'will'' phase
    elseif (phase == 'did') then
        -- kickoff physics
        -- * physics envirionment * --
 
        if (gameShips) then
--            -- add physics for alien ships
--            for k, v in pairs(attackersNames) do
--                print(k, v)
--                if (v=='bigShip') then                
--                    physics.addBody(attackers[v], {shape=gameShips.alienShips.bigShip.shape})
--                    attackers[v].isSensor = gameShips.alienShips.bigShip.isSensor
--                elseif (v=='smallShip1') then
--                    physics.addBody(attackers[v], {shape=gameShips.alienShips.smallShip1.shape})
--                    attackers[v].isSensor = gameShips.alienShips.smallShip1.isSensor
--                elseif (v=='smallShip2') then 
--                    physics.addBody(attackers[v], {shape=gameShips.alienShips.smallShip1.shape})
--                    attackers[v].isSensor = gameShips.alienShips.smallShip1.isSensor
--                end
--                attackers[v].bodyType = 'dynamic'   
--                attackers[v].filter = {categoryBits=2, maskBits=16}
--                attackers[v].gravityScale = 0   
--            end -- foreach alien ships
--                    
--            
            -- playerShip events
            playerShip.touch = playerTouchHandler
            playerShip:addEventListener('touch', playerShip)
            playerShip.tap = playerTapHandler
            playerShip:addEventListener('tap', playerShip)            
        elseif (err) then
            print(err)
        end-- end if gameShips data   
        
        startGame()
        
    end -- end show() did phase
end -- scene:show()

function scene:hide(event)     
    local sceneGroup = self.view
    local phase = event.phase
    backToHomeButton.isVisible = false
end

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

