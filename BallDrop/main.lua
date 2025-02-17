-- Game variables
local paddle = { x = 0, y = -1.5, z = -3, width = 1, height = 0.1, thickness = 0.05 }
local objects = {}
local score = 0
local objectSpeed = 1
local spawnRate = 1
local timeSinceLastSpawn = 0

-- Function to spawn a new falling object
local function spawnObject()
    local object = {
        x = math.random(-1, 1), -- Random horizontal position
        y = 2, -- Start at the top
        z = -3, -- Same depth as the paddle
        size = 0.2,
        vy = -objectSpeed, -- Vertical velocity (falling down)
        caught = false
    }
    table.insert(objects, object)
end

-- Input handling
function lovr.keypressed(key)
    if key == '1' then
        paddle.x = paddle.x - 0.2 -- Move left
    elseif key == '2' then
        paddle.x = paddle.x + 0.2 -- Move right
    end

    -- Clamp paddle position to keep it within the screen bounds
    paddle.x = math.max(-1.5, math.min(1.5, paddle.x)) -- Adjust bounds as needed
end

-- Update function
function lovr.update(dt)
    -- Spawn new objects
    timeSinceLastSpawn = timeSinceLastSpawn + dt
    if timeSinceLastSpawn > spawnRate then
        spawnObject()
        timeSinceLastSpawn = 0
    end

    -- Update falling objects
    for i = #objects, 1, -1 do
        local object = objects[i]
        object.y = object.y + object.vy * dt -- Update position using velocity

        -- Check if the object hits the paddle
        if not object.caught and
           object.y < paddle.y + paddle.height / 2 and
           object.x > paddle.x - paddle.width / 2 and
           object.x < paddle.x + paddle.width / 2 then
            object.vy = -object.vy -- Reverse vertical velocity (bounce)
            score = score + 1
            objectSpeed = objectSpeed + 0.1 -- Increase difficulty
        end

        -- Remove objects that fall off the screen
        if object.y < -2 then
            table.remove(objects, i)
        end
    end
end

-- Draw function
function lovr.draw(pass)
    -- Draw the paddle as a flat rectangle with thickness
    pass:setColor(0, 1, 1)
    pass:plane(paddle.x, paddle.y, paddle.z, paddle.width, paddle.height)

    -- Draw the falling objects
    pass:setColor(1, 0, 0)
    for _, object in ipairs(objects) do
        pass:sphere(object.x, object.y, object.z, object.size)
    end

    -- Draw the score
    pass:setColor(1, 1, 1)
    pass:text('Score: ' .. score, 0, 1.7, -3, 0.2)
end