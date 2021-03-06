PlayState = Class {__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.health = params.health
  self.score = params.score
  self.ball = params.ball

  -- give ball random starting velocity
  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-50, -60)
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
    return
  end

  -- update positions based on velocity
  self.paddle:update(dt)
  self.ball:update(dt)

  if self.ball:collides(self.paddle) then
    -- raise ball above paddle in case it goes below it, then reverse dy
    self.ball.y = self.paddle.y - 8
    self.ball.dy = -self.ball.dy

    --
    -- tweak angle of bounce based on where it hits the paddle
    --

    -- if we hit the paddle on its left side while moving left...
    if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
      -- else if we hit the paddle on its right side while moving right...
      self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
    elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
      self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
    end

    gSounds["paddle-hit"]:play()
  end

  -- detect collision across all bricks with the ball
  for k, brick in pairs(self.bricks) do
    -- only check collision if we're in play
    if brick.inPlay and self.ball:collides(brick) then
      -- add to score
      self.score = self.score + 10

      -- trigger the brick's hit function, which removes it from play
      brick:hit()

      --
      -- collision code for bricks
      --
      -- we check to see if the opposite side of our velocity is outside of the brick;
      -- if it is, we trigger a collision on that side. else we're within the X + width of
      -- the brick and should check to see if the top or bottom edge is outside of the brick,
      -- colliding on the top or bottom accordingly
      --

      -- left edge; only check if we're moving right, and offset the check by a couple of pixels
      -- so that flush corner hits register as Y flips, not X flips
      if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
        -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
        -- so that flush corner hits register as Y flips, not X flips
        -- flip x velocity and reset position outside of brick
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x - 8
      elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then
        -- top edge if no X collisions, always check
        -- flip x velocity and reset position outside of brick
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x + 32
      elseif self.ball.y < brick.y then
        -- bottom edge if no X collisions or top collision, last possibility
        -- flip y velocity and reset position outside of brick
        self.ball.dy = -self.ball.dy
        self.ball.y = brick.y - 8
      else
        -- flip y velocity and reset position outside of brick
        self.ball.dy = -self.ball.dy
        self.ball.y = brick.y + 16
      end

      -- slightly scale the y velocity to speed up the game
      self.ball.dy = self.ball.dy * 1.02

      -- only allow colliding with one brick, for corners
      break
    end
  end

  -- if ball goes below bounds, revert to serve state and decrease health
  if self.ball.y >= VIRTUAL_HEIGHT then
    self.health = self.health - 1
    gSounds["hurt"]:play()

    if self.health == 0 then
      gStateMachine:change(
        "game-over",
        {
          score = self.score
        }
      )
    else
      gStateMachine:change(
        "serve",
        {
          paddle = self.paddle,
          bricks = self.bricks,
          health = self.health,
          score = self.score
        }
      )
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

  renderScore(self.score)
  renderHealth(self.health)

  -- pause text, if paused
  if self.paused then
    love.graphics.setFont(gFonts["large"])
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, "center")
  end
end
