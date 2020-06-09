PlayState = Class {__includes = BaseState}

function PlayState:init()
  self.paddle = Paddle()
  -- initialize ball with skin #1; different skins = different sprites
  self.ball = Ball(1)

  --give ball random starting velocity
  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-50, -60)

  -- init ball center position
  self.ball.x = VIRTUAL_WIDTH / 2 - 4
  self.ball.y = VIRTUAL_HEIGHT - 42

  -- use the "static" createMap function to generate a bricks table
  self.bricks = LevelMaker.createMap()
end

function PlayState:update(dt)
  if self.paused then
    if love.keyboard.wasPressed("space") then
      self.paused = false
      gSounds["pause"]:play()
    else
      return
    end
  elseif love.keyboard.wasPressed("space") then
    self.paused = true
    gSounds["pause"]:play()
  end

  -- update positions based on velocity
  self.paddle:update(dt)
  self.ball:update(dt)

  if self.ball:collides(self.paddle) then
    -- reverse Y velocity if collision detected with paddle
    self.ball.dy = -self.ball.dy
    gSounds["paddle-hit"]:play()
  end

  -- collision detection accros all bricks
  for k, brick in pairs(self.bricks) do
    -- only check collision if we are in play
    if brick.inPlay and self.ball:collides(brick) then
      -- triger the brick's hit function which removes it from play
      brick:hit()
    end
  end

  if love.keyboard.wasPressed("escape") then
    love.event.quit()
  end
end

function PlayState:render()
  -- render bricks
  for k, brick in pairs(self.bricks) do
    brick:render()
  end

  self.paddle:render()
  self.ball:render()

  --pause text if paused
  if self.paused then
    love.graphics.setFont(gFonts["large"])
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, "center")
  end
end
