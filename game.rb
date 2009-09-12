#!/usr/bin/env ruby

require 'rubygems'
require 'gosu'
srand

class GameWindow < Gosu::Window

  def initialize
    super(800, 600, false)

    @player = Player.new(self)
    @meteor = Meteor.new(self)
  end
  
  def update
    # Quit?
    exit if button_down? Gosu::Button::KbEscape

    @player.update
    @meteor.update
  end
  
  def draw
    @player.draw
    @meteor.draw
  end

end


class Player
  attr_accessor :window, :x, :y, :angle, :size
  
  def initialize(window)
    @window = window

    # Place the Player in the center of the GameWindow
    @x = window.width / 2
    @y = window.height / 2
    @angle = 0
    @size = 30
    
    @speed_x = 0
    @speed_y = 0

    @image = Gosu::Image.new(window, 'resources/graphics/player.png')
  end
  
  def update
    # Rotate left and right
    @angle += 4 if window.button_down? Gosu::Button::KbRight
    @angle -= 4 if window.button_down? Gosu::Button::KbLeft

    # Increase the speed along the axis
    if window.button_down? Gosu::Button::KbUp
      @speed_x += Gosu::offset_x(self.angle, 0.5)
      @speed_y += Gosu::offset_y(self.angle, 0.5)
    end

    # Friction
    @speed_x = @speed_x * 0.97
    @speed_y = @speed_y * 0.97

    # Move the player
    @x += @speed_x
    @y += @speed_y

    # Keep the player on the screen. This isn't totally perfect, but works for now
    @x += window.width if @x < 0
    @x -= window.width if @x > window.width
    @y += window.height if @y < 0
    @y -= window.height if @y > window.height
  end
  
  def draw
    @image.draw_rot(self.x, self.y, 0, self.angle)
  end
  
end

class Meteor
  attr_accessor :window, :x, :y, :angle, :size

  def initialize(window)
    @window = window

    # Place the Meteor in the center of the GameWindow
    @x = 0
    @y = 0
    @angle = Gosu::random(0, 359)
    @rotation_speed = Gosu::random(-1, 1)
    @size = 80
    
    @speed_x = Gosu::random(-2, 2)
    @speed_y = Gosu::random(-2, 2)

    @image = Gosu::Image.new(window, 'resources/graphics/meteor_1.png')
  end

  def update
    # Move the meteor
    @x += @speed_x
    @y += @speed_y

    @angle += @rotation_speed

    # Keep the meteor on the screen. This isn't totally perfect, but works for now
    @x += window.width if @x < 0
    @x -= window.width if @x > window.width
    @y += window.height if @y < 0
    @y -= window.height if @y > window.height
  end

  def draw
    @image.draw_rot(self.x, self.y, 0, self.angle)
  end

end

GameWindow.new.show
