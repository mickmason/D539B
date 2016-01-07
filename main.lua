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

-- * Game page group dimenstions * --
local gamePageGroup = display.newGroup()
-- max widths and game boundaries --
gamePageGroup.width = displayWidth - 10 --5px padding on either side
gamePageGroup.height = displayHeight - 30 --30px padding on the top of the game area
gamePageGroup.maxXLeft = displayCenter.x - gamePageGroup.width * 0.5 
gamePageGroup.maxXRight = displayCenter.x + gamePageGroup.width * 0.5 
gamePageGroup.maxTop = displayCenter.y - gamePageGroup.height * 0.5 
gamePageGroup.maxBottom = displayCenter.y + gamePageGroup.height * 0.5 

player = {
    uname = 'Michael'
}
------------------------------------------
-- ** Game UI elements: score, timer ** --
------------------------------------------
local gameUIGroup = display.newGroup()
gamePageGroup:insert(gameUIGroup)
local score = display.newText({parent=gameUIGroup, text='100', font=gameBaseFont, fontSize=22, height=100, align='right', width=(displayWidth*0.5)-20})
score.anchorX, score.anchorY  = 0,0
score.x = displayWidth*0.5
score.y = -25
score.score = 0
score.text = score.score
local countdown = display.newText({parent=gameUIGroup, text='01:00', font=gameBaseFont, fontSize=22, height=100, align='left', width=(displayWidth*0.5)})
countdown.anchorX, countdown.anchorY  = 0,0
countdown.y = -25
countdown.x = 20

--Game lasts 1 minute
local gameLength = 1 * 60
--Timer function
function timerCount() 
    gameLength = gameLength - 1
    local mins = math.floor(gameLength/60)
    local secs = gameLength % 60
    countdown.text = string.format( "%02d:%02d", mins, secs )    
end

function startTimer() 
    timerRef = timer.performWithDelay(1000, timerCount, gameLength)
end
function pauseTimer() 
    if (timerRef ~= nil) then timer.pause(timerRef) end
end
function pauseTimer() 
    if (timerRef ~= nil) then timer.resume(timerRef) end
end

--increment the score - takes an alien ships and gets its hit score
function incrementScore(hitShip)
    score.score = score.score + hitShip.killScore
    score.text = score.score
end
-----------------------------
-- ** Game objects JSON ** --
-----------------------------
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
            smallShip1 =    {
                shape = {2,-14, 5.18,-9.68, 14,-2.63, 9.52,3.27, 7.1,6.15, 0,14, -7.1,6.15, -9.52,3.27, -14,-2.64, -5.18,-9.68 },
                image_path = 'small_attacker_1.png',
                bodyType = 'dynamic',
                isSensor = true,
                categoryFilter = {categoryBits=2, maskBits=16},
                shipMaxHits = 7,
                killScore = 60,
                laserPower = 10
            },
            randomShip = {
                shape = {16,16, 16,-3, 14.45,0.87, 12.73,3.37, 8.53,8.05, 6.43,10.11, 0,16, -6.43,10.11, -8.53,8.05, -12.73,3.37, -14.45,0.87, -16,-3},
                image_path = 'small_attacker_1.png',
                bodyType = 'dynamic',
                isSensor = true,
                categoryFilter = {categoryBits=1, maskBits=16},
                shipMaxHits = 7,
                killScore = 60,
                laserPower = 10
            }
    },
    playerShip = {
            shape = {0,-28, 3.69,-19.75, 3.69,-3, 56,56, 0.0,56, -3.69,-3, -3.69,-19.75},
            image_path = 'player.png',
            bodyType = 'dynamic',
            isSensor = true,
            ki = 100,
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
physics.addBody(playerShip, {shape=gameShips.playerShip.shape})
playerShip.gravityScale = 0
playerShip.isSensor = gameShips.playerShip.isSensor
playerShip.filter =  gameShips.playerShip.categoryFilter
playerShip.name = "Player ship"


--------------------------
-- ** Game functions ** --
--------------------------
--***Player laser shot collision handler **--
function laserOnCollision(self,event)
    if (event.phase == 'began') then
        print('Laser collision began with '..event.other.name)print('Self x,y '..self.x..','..self.y)
--        print('Other x,y '..event.other.x..','..event.other.y)
--        print('Event x,y '..event.x..','..event.y)
        local alienShip = event.other
        alienShip.hitCount = alienShip.hitCount + 1
        local expl = nil
        if (alienShip.hitCount == alienShip.shipMaxHits) then
            --create an explosion animation
            expl = animations.make_medium_explosion()
            expl:addEventListener('sprite', animations.sprite_listener)
            expl.x,expl.y = self.x,self.y 
            expl.isVisible = true
            expl:play()
            incrementScore(alienShip)
            display.remove(alienShip)
        else
            --create an explosion animation
            expl = animations.make_small_explosion()
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
    local shot = createLaserShot()
    shot.x = playerShip.x
    shot.isVisible = true
    local params = {
        time = 800,
        transition = easing.inOutQuad,
        onStart = function() 
            print('Start shot x: '..shot.x)
            print('Start shot y: '..shot.y)
        end,
        onComplete = function() 
            print('End shot x: '..shot.x)
            print('End shot y: '..shot.y)
            display.remove(shot)
        end,
        x=shot.x, 
        y=-1000
    }
    shot.transitionId =  transition.to(shot, params)
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
--Add the ships for the attackers for this round
local attackersNames = {'bigShip', 'smallShip1', 'smallShip2'}
local attackers = {}
for k, v in pairs(attackersNames) do
    if (v=='bigShip') then
        attackers[v] = display.newImage("assets/"..gameShips.alienShips.bigShip.image_path)
        attackers[v].y = 0
        --attackers[v].strokeWidth = 1
        attackers[v].name = 'Big ship 1'
        attackers[v].shipMaxHits = gameShips.alienShips.bigShip.shipMaxHits
        attackers[v].killScore = gameShips.alienShips.bigShip.killScore
        attackers[v].laserPower = gameShips.alienShips.bigShip.laserPower        
        gameGroup:insert(attackers[v])
        attackers[v].x = gameGroup.center.x
        physics.addBody(attackers[v], {shape=gameShips.alienShips.bigShip.shape})
        attackers[v].isSensor = gameShips.alienShips.bigShip.isSensor
    elseif (v=='smallShip1') then
        attackers[v] = display.newImage("assets/"..gameShips.alienShips.smallShip1.image_path)
        attackers[v].y = 64
        attackers[v].name = 'Small ship 1'
        attackers[v].shipMaxHits = gameShips.alienShips.smallShip1.shipMaxHits
        attackers[v].killScore = gameShips.alienShips.smallShip1.killScore
        attackers[v].laserPower = gameShips.alienShips.smallShip1.laserPower
        gameGroup:insert(attackers[v])
        attackers[v].x = displayCenter.x - (gameGroup.width * 0.25)
        physics.addBody(attackers[v], {shape=gameShips.alienShips.smallShip1.shape})
        attackers[v].isSensor = gameShips.alienShips.smallShip1.isSensor
    elseif (v=='smallShip2') then 
        attackers[v] = display.newImage("assets/"..gameShips.alienShips.smallShip1.image_path)
        attackers[v].y = 64
        attackers[v].name = 'Small ship 2'

        attackers[v].shipMaxHits = gameShips.alienShips.smallShip1.shipMaxHits
        attackers[v].killScore = gameShips.alienShips.smallShip1.killScore
        attackers[v].laserPower = gameShips.alienShips.smallShip1.laserPower
        gameGroup:insert(attackers[v])
        attackers[v].x = displayCenter.x + (gameGroup.width * 0.25)
        physics.addBody(attackers[v], {shape=gameShips.alienShips.smallShip1.shape})
        attackers[v].isSensor = gameShips.alienShips.smallShip1.isSensor
    end
    attackers[v].hitCount = 0
    attackers[v].bodyType = 'dynamic'   
    attackers[v].filter = {categoryBits=2, maskBits=16}
    attackers[v].gravityScale = 0   
end








