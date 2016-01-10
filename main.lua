require "CiderDebugger";
animations = require("animations")

local physics = require "physics"

-----------------------------
-- ** Global properties ** --
-----------------------------
-- * physics envirionment * --
physics.start()
physics.setReportCollisionsInContentCoordinates(true)
physics.setReportCollisionsInContentCoordinates( true)

-- * Display dimensions * --
local displayWidth = display.contentWidth
local displayHeight = display.contentHeight
local pageWidth = displayWidth - 20
local displayCenter = {
    x = display.contentWidth * 0.5,
    y = display.contentHeight * 0.5
}
-- * Default font * --
local sysFonts = native.getFontNames()
local gameBaseFont = 'Courier'

-- * Set up page padding * --
local pagePadding = {
    top = 30, bottom = 10, left = 15, right = 15
}
-----------------
-- ** Pages ** --
-----------------
-- app group --
 
-- ** Landing page group ** --
local landingPageGroup = display.newGroup() 
landingPageGroup.width = pageWidth --5px padding on either side
landingPageGroup.height = displayHeight - 30 --30px padding on the top of the game area
local topScoresGroup = display.newGroup() 
landingPageGroup:insert(topScoresGroup)

-- ** Game page group ** --
---- * dimenstions * -----
local gamePageGroup = display.newGroup()
-- max widths and game boundaries --
gamePageGroup.width = displayWidth - 10 --5px padding on either side
gamePageGroup.height = displayHeight - 30 --30px padding on the top of the game area
gamePageGroup.maxXLeft = displayCenter.x - gamePageGroup.width * 0.5 
gamePageGroup.maxXRight = displayCenter.x + gamePageGroup.width * 0.5 
gamePageGroup.maxTop = displayCenter.y - gamePageGroup.height * 0.5 
gamePageGroup.maxBottom = displayCenter.y + gamePageGroup.height * 0.5 

player = {
    username = 'michael__'
}
-- * Some timer references for alien behaviours * -- 
local alienShooterTimerRef = nil
local alienMovementTimerRef = nil
--------------------------------------------------------------------
-- ** Game UI elements: start button, score, timer, life force ** --
--------------------------------------------------------------------
local gameUIGroup = display.newGroup()
gamePageGroup:insert(gameUIGroup)
-- score
local score = display.newText({parent=gameUIGroup, text='100', font=gameBaseFont, fontSize=22, height=100, align='right', width=(displayWidth*0.5)-20})
score.anchorX, score.anchorY  = 0,0
score.x = displayWidth*0.5
score.y = -25
score.score = 0
score.text = score.score
--countdown
local countdown = display.newText({parent=gameUIGroup, text='01:00', font=gameBaseFont, fontSize=22, height=100, align='left', width=(displayWidth*0.5)})
countdown.anchorX, countdown.anchorY  = 0,0
countdown.y = -25
countdown.x = 20

-- Game lasts 1 minute
local gameLength = 1 * 60
-- Game clock timer ref
local clockTimerRef = 0
-- Lifeforce indicator
local lfIndicator = display.newRect(displayWidth, displayHeight, displayWidth*0.23, 3, 2)
gameUIGroup:insert(lfIndicator)
lfIndicator.x = displayWidth-lfIndicator.width - 10 
lfIndicator.initialWidth = lfIndicator.width
lfIndicator:setFillColor(0.1,0.8,0.1)
lfIndicator.anchorX, lfIndicator.anchorY  = 0,0
local lfIndicatorBG = display.newRect(lfIndicator.x - 1, lfIndicator.y -1, lfIndicator.width+2, lfIndicator.height+2, 2)
gameUIGroup:insert(lfIndicatorBG)
lfIndicatorBG.anchorX, lfIndicatorBG.anchorY = 0,0
lfIndicatorBG:setFillColor(0.3,0.3,0.3)
lfIndicator:toFront()

-- Game over text
local gameOver = display.newText({parent=gameUIGroup, text='Game over', font=gameBaseFont, fontSize=32, height=100, align='center', width=(displayWidth*0.5)})
gameOver.isVisible = false
gameOver.x, gameOver.y = displayCenter.x, displayCenter.y - displayHeight * 0.23
local gameOverScore = display.newText({parent=gameUIGroup, text='Score', font=gameBaseFont, fontSize=22, height=100, align='center', width=(displayWidth*0.5)})
gameOverScore.isVisible = false
gameOverScore.x, gameOverScore.y = displayCenter.x, gameOver.y + 50

--Back to home button
local backToHomeButton = display.newRect(gameOverScore.x, gameOverScore.y+20, displayWidth*0.45, 34, 2)
gameUIGroup:insert(lfIndicator)
backToHomeButton:setFillColor(0.3,0.3,0.3)
backToHomeButton.isVisible = false
local backToHomeButtonText = display.newText({parent=gameUIGroup, text='Back to home', font=gameBaseFont, fontSize=18, height=backToHomeButton.height, align='center', width=(displayWidth*0.5)})
backToHomeButtonText.x, backToHomeButtonText.y = backToHomeButton.x, backToHomeButton.y+6
backToHomeButtonText.isVisible = false
backToHomeButton:toBack()

function backToHomeButtonTap() 
    --do paging back to landing page
end
--countdown function
function timerCount() 
    gameLength = gameLength - 1
    local mins = math.floor(gameLength/60)
    local secs = gameLength % 60
    countdown.text = string.format( "%02d:%02d", mins, secs )    
end

function startTimer() 
    clockTimerRef = timer.performWithDelay(1000, timerCount, gameLength)
end
function pauseTimer() 
    if (clockTimerRef ~= nil) then timer.pause(clockTimerRef) end
end
function resumeTimer() 
    if (clockTimerRef ~= nil) then timer.resume(clockTimerRef) end
end

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
--------------------------------------------------------------------
---- -- -- -- --  ** End game UI elements ** -- -- -- -- -- -- -- -- 
--------------------------------------------------------------------
-- from JSON --
local topScores = {
    {
        username = {
            'michael__'
        },
        scores = {
            220, 220, 160, 120, 100
        },
        password = 'passw0rd'
    }
}
-- ** user top scores ** --
local scoresData = {
    userScores = {
    }
} 
for i in ipairs(topScores) do
    for k,v in pairs(topScores[i]) do
        if (k == 'scores') then
            scoresData.userScores = v
        end
    end
end
for i in ipairs(scoresData.userScores) do
       print(scoresData.userScores[i])
end

function updateScoresData() 
    local highScoreIndex = 0
    local userScore = tonumber(score.text)
        
        for i in ipairs(scoresData.userScores) do
            
            if (userScore > scoresData.userScores[i] or userScore == scoresData.userScores[i]) then
                print('User score: '..userScore)
                print('Scores data i: '..scoresData.userScores[i])
                highScoreIndex = i
                break
            end
        end
        if (highScoreIndex > 1) then 
            table.insert(scoresData.userScores, highScoreIndex, userScore)
            table.remove(scoresData.userScores, #scoresData.userScores)
        end

    for i in ipairs(scoresData.userScores) do
       print(scoresData.userScores[i])
    end
end

-- ** Game start, stop, pause ** --
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
    updateScoresData()
    gameOverScore.text = 'Score: '..score.text
    gameOverScore.isVisible = true
    gameOver.isVisible = true
    backToHomeButton.isVisible = true
    backToHomeButtonText.isVisible = true
end

-----------------------------------------
-- ** Game objects to and from JSON ** --
-----------------------------------------


local gameShips = {
    alienShips = {
            bigShip = {
                shape = {-3,-24, 3,-24, 24,-1.3, 16.55,3.67, 1.57,24, -1.57,24, -16.55,3.67, -24,-1.3},
                image_path = 'attacker_1.png',
                bodyType = 'dynamic',
                isSensor = true,
                categoryFilter = {categoryBits=1, maskBits=16},
                shipMaxHits = 10,
                killScore = 100,
                laserPower = 20
            },
            smallShip1 = {
                shape = {2,-14, 5.18,-9.68, 14,-2.63, 9.52,3.27, 7.1,6.15, 0,14, -7.1,6.15, -9.52,3.27, -14,-2.64, -5.18,-9.68 },
                image_path = 'small_attacker_1.png',
                bodyType = 'dynamic',
                isSensor = true,
                categoryFilter = {categoryBits=2, maskBits=16},
                shipMaxHits = 5,
                killScore = 60,
                laserPower = 10
            },
	    alienLaserShot = {
		shape = {0,-45, 2.50,-23.3, 2.91,0, 2.91,45, -2.91,45, -2.91,0, -2.50,-23.3},
                image_path = 'alien_shot.png',
                bodyType = 'dynamic',
                isSensor = true,
                categoryFilter = {categoryBits=8, maskBits=4},
                laserPower = 10
	    }
    },
    playerShip = {
            shape = {0,-28, 3.69,-19.75, 3.69,-3, 56,56, 0.0,56, -3.69,-3, -3.69,-19.75},
            image_path = 'player.png',
            bodyType = 'dynamic',
            isSensor = true,
            ki = 300,
            laserShot = {
                shape = {0,-85, 5,-23.5, 5,55, -5,55, -5,-23.5 },
                image_path = 'player_shot.png',
                isSensor = true,
                bodyType = 'Dynamic',
                categoryFilter = {categoryBits=16, maskBits=3}
            },
            categoryFilter = {categoryBits=4, maskBits=8}
    }
}

-----------------------------------
-- ** Set up the game objects ** --
------------------------------------- 
--game group - contains the attacker and player ships
local gameGroup = display.newGroup();
gameGroup.width, gameGroup.height = displayWidth,displayHeight 
gamePageGroup:insert(gameGroup)
gameGroup.y = 50
gameGroup.center = {
    x = displayCenter.x,
    y = displayCenter.y
}

--Add the player
local playerShip = display.newImage(gameGroup, "assets/"..gameShips.playerShip.image_path)
playerShip.x = displayCenter.x
playerShip.y = displayHeight - playerShip.height - 50
physics.addBody(playerShip, {shape=gameShips.playerShip.shape, filter =  gameShips.playerShip.categoryFilter})
playerShip.gravityScale = 0
playerShip.isSensor = gameShips.playerShip.isSensor
playerShip.name = "Player ship"
playerShip.ki = gameShips.playerShip.ki
playerShip.startKi = playerShip.ki

--Alien ships for this round
local attackersNames = {'bigShip', 'smallShip1', 'smallShip2'}
local attackers = {}
local attackersCount = 0
for k, v in pairs(attackersNames) do
    if (v=='bigShip') then
        attackers[v] = display.newImage("assets/"..gameShips.alienShips.bigShip.image_path)
        attackers[v].y = 0
        --attackers[v].strokeWidth = 1
        attackers[v].name = v
        attackers[v].shipMaxHits = gameShips.alienShips.bigShip.shipMaxHits
        attackers[v].killScore = gameShips.alienShips.bigShip.killScore
        attackers[v].laserPower = gameShips.alienShips.bigShip.laserPower        
        gameGroup:insert(attackers[v])
        attackers[v].x = gameGroup.center.x
        physics.addBody(attackers[v], {shape=gameShips.alienShips.bigShip.shape})
        attackers[v].isSensor = gameShips.alienShips.bigShip.isSensor
        attackers[v].idx = attackersCount +1 
    elseif (v=='smallShip1') then
        attackers[v] = display.newImage("assets/"..gameShips.alienShips.smallShip1.image_path)
        attackers[v].y = 64
        attackers[v].name = v
        attackers[v].shipMaxHits = gameShips.alienShips.smallShip1.shipMaxHits
        attackers[v].killScore = gameShips.alienShips.smallShip1.killScore
        attackers[v].laserPower = gameShips.alienShips.smallShip1.laserPower
        gameGroup:insert(attackers[v])
        attackers[v].x = displayCenter.x - (gameGroup.width * 0.25)
        physics.addBody(attackers[v], {shape=gameShips.alienShips.smallShip1.shape})
        attackers[v].isSensor = gameShips.alienShips.smallShip1.isSensor
        attackers[v].idx = attackersCount +1       
        attackers[v].isMaxLeft = true
    elseif (v=='smallShip2') then 
        attackers[v] = display.newImage("assets/"..gameShips.alienShips.smallShip1.image_path)
        attackers[v].y = 64
        attackers[v].name = v
        attackers[v].shipMaxHits = gameShips.alienShips.smallShip1.shipMaxHits
        attackers[v].killScore = gameShips.alienShips.smallShip1.killScore
        attackers[v].laserPower = gameShips.alienShips.smallShip1.laserPower
        gameGroup:insert(attackers[v])
        attackers[v].x = displayCenter.x + (gameGroup.width * 0.25)
        physics.addBody(attackers[v], {shape=gameShips.alienShips.smallShip1.shape})
        attackers[v].isSensor = gameShips.alienShips.smallShip1.isSensor
        attackers[v].idx = attackersCount +1         
        attackers[v].isMaxRight = true
    end
     
    attackers[v].hitCount = 0
    attackers[v].bodyType = 'dynamic'   
    attackers[v].filter = {categoryBits=2, maskBits=16}
    attackers[v].gravityScale = 0   
    attackersCount = attackersCount + 1
end

--------------------------
-- ** Game functions ** --
--------------------------
--***Player laser shot collision handler **--
function laserOnCollision(self,event)
    if (event.phase == 'began') then
        print('Laser collision began with '..event.other.name)
        print('Self x,y '..self.x..','..self.y)
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
        transition.cancel(self.transitionId)        
        display.remove(self)
        return true
    elseif (event.phase == 'ended') then
        print('Laser collision ended  '..self.name)
        transition.cancel(self.transitionId)
        return true
    end
end
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
--Function which fires the player laser
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

end

--Player taps ship
function playerTapListener(self,event)
        fireTheLaser()
end
--player touch listener
function playerTouchListener(self,event) 
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
end
playerShip.touch = playerTouchListener
playerShip:addEventListener('touch', playerShip)
playerShip.tap = playerTapListener
playerShip:addEventListener('tap', playerShip)

--------------------------------
-- ** Alien ship functions ** --
-------------------------------- 

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
    local maxRight = displayWidth - 10
    --a single move on the y axis
    local yMove = 5
    --a single move on the x axis
    local xMove = displayWidth / 31

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

function startGame() 
    alienMovementTimerRef = timer.performWithDelay(1000, moveAliens, -1)  
    --alien shots timer
    alienShooterTimerRef = timer.performWithDelay(600, alienFireTheLaser, -1) 
    startTimer()
end

startGame()