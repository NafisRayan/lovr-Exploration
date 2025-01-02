-- Game variables
local paddle = { x = 0, y = -1.5, z = -3, width = 0.5, height = 0.1 }
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
        caught = false
    }
    table.insert(objects, object)
end

-- Update function
function lovr.update(dt)
    -- Move the paddle with the controller or keyboard
    if lovr.headset.getDriver() == 'desktop' and lovr.keyboard then
        local speed = 2 * dt
        if lovr.keyboard.isDown('left') then
            paddle.x = paddle.x - speed
        elseif lovr.keyboard.isDown('right') then
            paddle.x = paddle.x + speed
        end
    elseif lovr.headset.getDriver() == 'vr' and lovr.headset.getControllers then
        -- Use the VR controller to move the paddle
        local controller = lovr.headset.getControllers()[1]
        if controller then
            local x, y, z = controller:getPosition()
            paddle.x = x
        end
    end

    -- Spawn new objects
    timeSinceLastSpawn = timeSinceLastSpawn + dt
    if timeSinceLastSpawn > spawnRate then
        spawnObject()
        timeSinceLastSpawn = 0
    end

    -- Update falling objects
    for i = #objects, 1, -1 do
        local object = objects[i]
        object.y = object.y - objectSpeed * dt

        -- Check if the object is caught by the paddle
        if not object.caught and
           object.y < paddle.y + paddle.height / 2 and
           object.x > paddle.x - paddle.width / 2 and
           object.x < paddle.x + paddle.width / 2 then
            object.caught = true
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
    -- Draw the paddle
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