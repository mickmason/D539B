explosion_sprite_params = {
        width = 60,
        height = 50,
        numFrames = 8
}
explosion_image_sheet = graphics.newImageSheet('assets/explosion_sprite.png', explosion_sprite_params)
small_explosion_seq = {
        name = 'small_exp',
        start = 1,
        count = 3,
        loopCount = 1,
        loopDirection = 'forward'
}
med_explosion_seq = {
        name = 'med_exp',
        start = 1,
        count = 5,
        loopCount = 1,
        loopDirection = 'forward'
}
dead_explosion_seq = {
        name = 'dead_exp',
        start = 3,
        count = 8,
        loopCount = 1,
        loopDirection = 'forward'
}
animations = {
    make_small_explosion = function() 
        local sprite = display.newSprite(explosion_image_sheet, small_explosion_seq)
        sprite.isVisible = false
        return sprite
    end,
    make_medium_explosion = function() 
        local sprite = display.newSprite(explosion_image_sheet, med_explosion_seq)
        sprite.isVisible = false
        return sprite
    end,
    make_dead_explosion = function() 
        local sprite = display.newSprite(explosion_image_sheet, dead_explosion_seq)
        sprite.isVisible = false
        return sprite
    end,
    sprite_listener = function(event)
       if (event.phase == 'ended') then display.remove(event.target) end 
    end
        
    
    
}
return(animations)

