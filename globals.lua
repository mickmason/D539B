-------------------------------------------
-- ** Global properties and functions ** --
-------------------------------------------
local globals = {
    functions = {
        readJsonFile = function(fileName)
            local path = system.pathForFile( fileName)
            local file, errorString = io.open( path, "r" )
            if not file then
                    return nil, errorString
            else
                    local json = require 'json'
                    local jsonTable = json.decode(file:read( "*a" ))
                    io.close(file)
                    return jsonTable
            end
            file = nil
        end,
        writeJsonFile = function(fileName, data)
            print('write file')
            local path = system.pathForFile( fileName)
            local file, errorString = io.open( fileName, "w" )
            if not file then
                        return errorString
            else
                local json = require 'json'
                local jsData = json.encode(data)
                file:write(jsData)
                io.close(file)
            end
            file = nil
            return true
        end,
        loadScoresData = function(data, username)
            local playerData = data
            local userScores
            if err then
                print("Error "..err)
                return err
            end        

            for k, users in pairs(playerData) do
                for i in pairs(users) do
                    for l, v in pairs(users[i]) do
                        if (l == 'username' and v == username) then
                            userScores = users[i].scores
                        end
                    end
                end
            end    
            return userScores
        end,
        updateScoresData = function(userScores, score)
            local highScoreIndex = 0
            local userScore = tonumber(score)
            for i in ipairs(userScores) do
                if (userScore > userScores[i] or userScore == userScores[i]) then
                    highScoreIndex = i
                    break
                end
            end
            if (highScoreIndex >= 1) then 
                table.insert(userScores, highScoreIndex, userScore)
                table.remove(userScores, #gameScoresData.userScores)
            end
            for i in ipairs(userScores) do
               print('line 231 '..userScores[i])
            end
            return userScores
        end, 
        updatePlayerData = function(playerData, userScores, username)
            for j in ipairs(playerData) do
                for i in pairs(playerData[j]) do
                    for l, v in pairs(playerData[j]) do
                        print(l)
                        if (l == 'username' and v == username) then
                            playerData[j][i].scores = userScores
                        end
                    end
                end
            end    
            return playerData
        end
    },
    dimensions = {
        displayWidth = display.contentWidth,
        displayHeight = display.contentHeight,
        displayCenter = {
            x = display.contentWidth * 0.5,
            y = display.contentHeight * 0.5
        },
        pagePadding = {
            top = 20, bottom = 10, left = 15, right = 15
        }
    },
    fonts = {
        sysFonts = native.getFontNames(),
        gameBaseFont = 'Courier'
    }
}

return globals

