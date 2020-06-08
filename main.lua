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
