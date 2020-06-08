--[[
    GD50
    Breakout Remake
    Author: Colton Ogden
    cogden@cs50.harvard.edu
    Originally developed by Atari in 1976. An effective evolution of
    Pong, Breakout ditched the two-player mechanic in favor of a single-
    player game where the player, still controlling a paddle, was tasked
    with eliminating a screen full of differently placed bricks of varying
    values by deflecting a ball back at them.
    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
    Credit for graphics (amazing work!):
    https://opengameart.org/users/buch
    Credit for music (great loop):
    http://freesound.org/people/joshuaempyre/sounds/251461/
    http://www.soundcloud.com/empyreanma
]]
require "src/Dependencies"

--[[Gmae init]]
function love.load()
  -- set love's default filter to "nearest-neighbor", which essentially
  -- means there will be no filtering of pixels (blurriness), which is
  -- important for a nice crisp, 2D look
  love.graphics.setDefaultFilter("nearest", "nearest")

  --seed the RNG so that calls to random are always random
  math.randomseed(os.time())

  -- set app title bar
  love.window.setTitle("Breakout")

  -- init Retro font
  gFonts = {
    ["small"] = love.graphics.newFont("fonts/font.ttf", 8),
    ["medium"] = love.graphics.newFont("fonts/font.ttf", 16),
    ["large"] = love.graphics.newFont("fonts/font.ttf", 32)
  }

  love.graphics.setFont(gFonts["small"])

  -- init graphics
  gTextures = {
    ["background"] = love.graphics.newImage("graphics/background.png"),
    ["main"] = love.graphics.newImage("graphics/breakout.png"),
    ["arrows"] = love.graphics.newImage("graphics/arrows.png"),
    ["hearts"] = love.graphics.newImage("graphics/hearts.png"),
    ["particle"] = love.graphics.newImage("graphics/particle.png")
  }

  -- init virtual resolution, which will be rendered within our actual window no metter the dimensions
  push:setupScreen(
    VIRTUAL_WIDTH,
    VIRTUAL_HEIGHT,
    WINDOW_WIDTH,
    WINDOW_HEIGHT,
    {
      vsync = true,
      fullscreen = false,
      resizable = true
    }
  )

  -- init sounds
  gSounds = {
    ["paddle-hit"] = love.audio.newSource("sound/paddle_hit.wav"),
    ["score"] = love.audio.newSource("sound/score.wav"),
    ["wall-hit"] = love.audio.newSource("sound/wall_hit.wav"),
    ["confirm"] = love.audio.newSource("sound/confirm.wav"),
    ["select"] = love.audio.newSource("sound/select.wav"),
    ["no-select"] = love.audio.newSource("sound/no-select.wav"),
    ["brick-hit-1"] = love.audio.newSource("sound/brick-hit-1.wav"),
    ["brick-hit-2"] = love.audio.newSource("sound/brick-hit-2.wav"),
    ["hurt"] = love.audio.newSource("sound/hurt.wav"),
    ["victory"] = love.audio.newSource("sound/victory.wav"),
    ["recover"] = love.audio.newSource("sound/recover.wav"),
    ["high-score"] = love.audio.newSource("sound/high-score.wav"),
    ["pause"] = love.audio.newSource("sound/pause.wav"),
    ["music"] = love.audio.newSource("sound/music.wav.wav")
  }

  -- the state machine we'll be using to transition between various states
  -- in our game instead of clumping them together in our update and draw
  -- methods
  --
  -- our current game state can be any of the following:
  -- 1. 'start' (the beginning of the game, where we're told to press Enter)
  -- 2. 'paddle-select' (where we get to choose the color of our paddle)
  -- 3. 'serve' (waiting on a key press to serve the ball)
  -- 4. 'play' (the ball is in play, bouncing between paddles)
  -- 5. 'victory' (the current level is over, with a victory jingle)
  -- 6. 'game-over' (the player has lost; display score and allow restart)

  gStateMachine =
    StateMachine {
    ["start"] = function()
      return StartState()
    end
  }

  gStateMachine:change("start")

  -- a table we'll use to keep track of which keys have been pressed this
  -- frame, to get around the fact that LÖVE's default callback won't let us
  -- test for input from within other functions
  love.keyboard.keyPressed = {}
end

-- allow resize without breaking pixels
function love.resize(w, h)
  push:resize(w, h)
end

--[[
    Called every frame, passing in `dt` since the last frame. `dt`
    is short for `deltaTime` and is measured in seconds. Multiplying
    this by any changes we wish to make in our game will allow our
    game to perform consistently across all hardware; otherwise, any
    changes we make will be applied as fast as possible and will vary
    across system hardware.
]]
function love.update(dt)
  gStateMachine:update(dt)

  --reset keys pressed
  love.keyboard.keyPressed = {}
end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
  love.keyboard.keyPressed[key] = true
end

--[[
    A custom function that will let us test for individual keystrokes outside
    of the default `love.keypressed` callback, since we can't call that logic
    elsewhere by default.
]]
function love.keyboard.wasPressed(key)
  if love.keyboard.keyPressed[key] then
    return true
  else
    return false
  end
end

--[[
    Called each frame after update; is responsible simply for
    drawing all of our game objects and more to the screen.
]]
function love.draw()
  push:apply("start")

  --background will be drawn regardless of state
  local backgroundWidth = gTextures["background"]:getWidth()
  local backgroundHeight = gTextures["background"]:getHeight()

  love.graphics.draw(
    getTextures["background"],
    0,
     --x
    0,
     --y
    0,
     -- rotation
    VIRTUAL_WIDTH / (backgroundWidth - 1), -- scale x
    VIRTUAL_HEIGHT / (backgroundHeight - 1) --scale y
  )
  -- use the state machine to defer rendering to the current state we're in
  gStateMachine:render()

  -- display FPS for debugging; simply comment out to remove
  displayFPS()

  push:apply("end")
end

--[[
    Renders the current FPS.
]]
function displayFPS()
  -- simple FPS display across all states
  love.graphics.setFont(gFonts["small"])
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 5, 5)
end
