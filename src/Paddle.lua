Paddle = Class {}

--[[
    Our Paddle will initialize at the same spot every time, in the middle
    of the world horizontally, toward the bottom.
]]
function Paddle:init()
  -- x is placed in the middle
  self.x = VIRTUAL_WIDTH / 2 - 32

  -- y is placed a little above the bottom edge of the screen
  self.y = VIRTUAL_HEIGHT - 32

  -- start us off with no velocity
  self.dx = 0

  -- starting dimensions
  self.width = 64
  self.height = 16

  -- the skin only has the effect of changing our color, used to offset us
  -- into the gPaddleSkins table later
  self.skin = 1

  -- the variant is which of the four paddle sizes we currently are; 2
  -- is the starting size, as the smallest is too tough to start with
  self.size = 2
end

function Paddle:update(dt)
  -- keyboard input
  if love.keyboard.isDown("left") then
    self.dx = -PADDLE_SPEED
  elseif love.keyboard.isDown("right") then
    self.dx = PADDLE_SPEED
  else
    self.dx = 0
  end

  -- math.max here ensures that we're the greater of 0 or the player's
  -- current calculated Y position when pressing up so that we don't
  -- go into the negatives; the movement calculation is simply our
  -- previously-defined paddle speed scaled by dt
  if self.dx < 0 then
    -- similar to before, this time we use math.min to ensure we don't
    -- go any farther than the bottom of the screen minus the paddle's
    -- height (or else it will go partially below, since position is
    -- based on its top left corner)
    self.x = math.max(0, self.x + self.dx * dt)
  else
    self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
  end
end

--[[
    Render the paddle by drawing the main texture, passing in the quad
    that corresponds to the proper skin and size.
]]
function Paddle:render()
  love.graphics.draw(gTextures["main"], gFrames["paddles"][self.size + 4 * (self.skin - 1)], self.x, self.y)
end