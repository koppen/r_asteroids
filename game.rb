#!/usr/bin/env ruby

require 'rubygems'
require 'gosu'

class GameWindow < Gosu::Window

  def initialize
    super(800, 600, false)

    @player = Player.new(self)
  end
  
  def update
    # Quit?
    exit if button_down? Gosu::Button::KbEscape

    @player.update
  end
  
  def draw
    @player.draw
  end

end


class Player
  attr_accessor :window, :x, :y, :angle
  
  def initialize(window)
    @window = window

    # Place the Player in the center of the GameWindow
    @x = window.width / 2
    @y = window.height / 2
    @angle = 0

    @image = Gosu::Image.new(window, 'resources/graphics/player.png')
  end
  
  def update
  end
  
  def draw
    @image.draw_rot(self.x, self.y, 0, self.angle)
  end
  
end



GameWindow.new.show
