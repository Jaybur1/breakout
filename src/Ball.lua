Ball = Class {}

function Ball:init(skin)
  -- simple positional and dimensional variables
  self.width = 8
  self.height = 8

  -- track valocity
  self.dy = 0
  self.dx = 0

  -- this will effectively be the color of our ball, and we will index
  -- our table of Quads relating to the global block texture using this
  self.skin = skin
end
