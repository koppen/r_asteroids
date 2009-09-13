#!/usr/bin/env ruby

require 'rubygems'
require 'gosu'
require 'activesupport'
class GameWindow < Gosu::Window

  def initialize
    super(800, 600, false)

    @actors = []
    @actors << Player.new(self)
    @actors << Meteor.new(self)
  end
  
  def update
    # Quit?
    exit if button_down? Gosu::Button::KbEscape

    @actors.each(&:update)
  end
  
  def draw
    @actors.each(&:draw)
  end

  def player
    @actors.find { |actor| actor.is_a?(Player) }
  end

end


class Actor
  attr_accessor :window, :x, :y, :angle, :size

  def draw
    @image.draw_rot(self.x, self.y, 0, self.angle)
  end
  
  def keep_on_screen
    radius = self.size / 2
    # Keep the player on the screen. This isn't totally perfect, but works for now
    @x = window.width + radius if @x < -radius
    @x = -radius if @x > window.width + radius
    @y = window.height + radius if @y < -radius
    @y = -radius if @y > window.height + radius
  end

  def move
    @x += @speed_x
    @y += @speed_y
  end
end

class Player < Actor

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

    self.move
    self.keep_on_screen
  end

  def die
    (@explosion ||= Gosu::Sample.new(self.window, 'resources/sounds/player_explosion.wav')).play

    # Center the player
    self.x = window.width / 2
    self.y = window.height / 2

    # Reset speeds
    @angle = @speed_x = @speed_y = 0
  end

end

class Meteor < Actor

  def initialize(window)
    @window = window

    # Place the Meteor in the center of the GameWindow
    @x = 0
    @y = 0
    @angle = Gosu::random(0, 359)
    @rotation_speed = Gosu::random(-1, 1)
    @size = 100

    @speed_x = Gosu::random(-2, 2)
    @speed_y = Gosu::random(-2, 2)

    @image = Gosu::Image.new(window, 'resources/graphics/meteor_1.png')
  end

  def update
    player = window.player
    distance_to_player = Gosu::distance(self.x, self.y, player.x, player.y)
    player.die if distance_to_player < (self.size + player.size) / 2

    @angle += @rotation_speed

    self.move
    self.keep_on_screen
  end

end

GameWindow.new.show
