-- Game variables
local player = { x = 0, y = 1.5, z = 0, speed = 3 }
local bullets = {}
local targets = {}
local score = 0
local spawnRate = 2
local timeSinceLastSpawn = 0
local gameTime = 60 -- 60-second timer
local gameOver = false
local crosshair = { x = 0, y = 1.5, z = -1, size = 0.01, speed = 2 } -- Crosshair position and properties

-- Check if lovr.keyboard is available
local hasKeyboard = type(lovr.keyboard) == "table"

-- Function to spawn a new target
local function spawnTarget()
    local target = {
        x = math.random(-2, 2), -- Random horizontal position
        y = math.random(1, 3),  -- Random vertical position
        z = -5,                 -- Fixed depth
        size = 0.3,
        speed = math.random(1, 3), -- Random movement speed
        direction = math.random() > 0.5 and 1 or -1, -- Random movement direction
        active = true
    }
    table.insert(targets, target)
end

-- Function to shoot a bullet
local function shootBullet()
    local bullet = {
        x = crosshair.x, -- Shoot from crosshair position
        y = crosshair.y,
        z = crosshair.z,
        speed = 10
    }
    table.insert(bullets, bullet)
    -- Play shoot sound (placeholder)
    -- lovr.audio.play(shootSound)
end

-- Update function
function lovr.update(dt)
    if gameOver then return end

    -- Update game timer
    gameTime = gameTime - dt
    if gameTime <= 0 then
        gameOver = true
    end

    -- Spawn new targets
    timeSinceLastSpawn = timeSinceLastSpawn + dt
    if timeSinceLastSpawn > spawnRate then
        spawnTarget()
        timeSinceLastSpawn = 0
    end

    -- Update bullets
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.z = bullet.z - bullet.speed * dt

        -- Remove bullets that go off-screen
        if bullet.z < -10 then
            table.remove(bullets, i)
        end
    end

    -- Update targets and check for collisions
    for i = #targets, 1, -1 do
        local target = targets[i]

        -- Move targets horizontally
        target.x = target.x + target.speed * target.direction * dt
        if target.x > 2 or target.x < -2 then
            target.direction = -target.direction -- Reverse direction at edges
        end

        -- Check for bullet collisions
        for j = #bullets, 1, -1 do
            local bullet = bullets[j]
            if target.active and
               bullet.x > target.x - target.size and
               bullet.x < target.x + target.size and
               bullet.y > target.y - target.size and
               bullet.y < target.y + target.size and
               bullet.z > target.z - target.size and
               bullet.z < target.z + target.size then
                target.active = false
                table.remove(bullets, j)
                score = score + 1
                -- Play hit sound (placeholder)
                -- lovr.audio.play(hitSound)
            end
        end

        -- Remove inactive targets
        if not target.active then
            table.remove(targets, i)
        end
    end

    -- Player movement (only if keyboard is available)
    if hasKeyboard then
        if lovr.keyboard.isDown('w', 'up') then
            player.z = player.z - player.speed * dt
        end
        if lovr.keyboard.isDown('s', 'down') then
            player.z = player.z + player.speed * dt
        end
        if lovr.keyboard.isDown('a', 'left') then
            player.x = player.x - player.speed * dt
        end
        if lovr.keyboard.isDown('d', 'right') then
            player.x = player.x + player.speed * dt
        end
    end
end

-- Draw function
function lovr.draw(pass)
    -- Draw the player
    pass:setColor(0, 1, 1)
    pass:sphere(player.x, player.y, player.z, 0.1)

    -- Draw bullets
    pass:setColor(1, 1, 0)
    for _, bullet in ipairs(bullets) do
        pass:sphere(bullet.x, bullet.y, bullet.z, 0.05)
    end

    -- Draw targets
    pass:setColor(1, 0, 0)
    for _, target in ipairs(targets) do
        if target.active then
            pass:sphere(target.x, target.y, target.z, target.size)
        end
    end

    -- Draw the crosshair
    pass:setColor(1, 1, 1)
    pass:plane(crosshair.x, crosshair.y, crosshair.z, crosshair.size, crosshair.size, 0, 1, 0, 0)

    -- Draw the score and timer
    pass:setColor(1, 1, 1)
    pass:text('Score: ' .. score, -0.5, 1.7, -3, 0.2)
    pass:text('Time: ' .. math.ceil(gameTime), 0.5, 1.7, -3, 0.2)

    -- Draw game-over screen
    if gameOver then
        pass:setColor(1, 0, 0)
        pass:text('Game Over!', 0, 1.5, -3, 0.3)
        pass:text('Final Score: ' .. score, 0, 1.2, -3, 0.2)
    end
end

-- Input handling
function lovr.keypressed(key)
    if key == 'space' then
        shootBullet()
    end

    -- Move crosshair with keys 1, 2, 3, 4
    if key == '1' then
        crosshair.x = crosshair.x - crosshair.speed * 0.1 -- Move left
    end
    if key == '2' then
        crosshair.x = crosshair.x + crosshair.speed * 0.1 -- Move right
    end
    if key == '3' then
        crosshair.y = crosshair.y - crosshair.speed * 0.1 -- Move down
    end
    if key == '4' then
        crosshair.y = crosshair.y + crosshair.speed * 0.1 -- Move up
    end
end

function lovr.controllerpressed(controller, button)
    if button == 'trigger' then
        shootBullet()
    end
end