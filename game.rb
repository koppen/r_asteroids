#!/usr/bin/env ruby

require 'rubygems'
require 'gosu'
require 'activesupport'
class GameWindow < Gosu::Window

  def initialize
    super(800, 600, false)

    @actors = []
    spawn_actor(Player.new(self))
    spawn_actor(Meteor.new(self))
    spawn_actor(Meteor.new(self))
    spawn_actor(Meteor.new(self))
    spawn_actor(Meteor.new(self))
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

  def meteors
    @actors.select { |actor| actor.is_a?(Meteor) }
  end

  def spawn_actor(actor)
    @actors << actor
  end

  def remove_actor(actor)
    @actors.delete(actor)
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
  attr_accessor :angle

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

    self.fire if window.button_down? Gosu::Button::KbLeftShift

    # Friction
    @speed_x = @speed_x * 0.97
    @speed_y = @speed_y * 0.97

    self.move
    self.keep_on_screen
  end

  def die
    self.window.spawn_actor(Explosion.new(self.window, self))

    # Center the player
    self.x = window.width / 2
    self.y = window.height / 2

    # Reset speeds
    @angle = @speed_x = @speed_y = 0
  end

  def fire
    return if Gosu::milliseconds < (@last_shot_at || 0) + 300
    @last_shot_at = Gosu::milliseconds

    (@fire ||= Gosu::Sample.new(self.window, 'resources/sounds/laser.wav')).play
    window.spawn_actor(Projectile.new(window, self)) 
  end

end

class Meteor < Actor

  def initialize(window, options = {})
    @window = window

    # Place the Meteor in the corner of the GameWindow
    @x = options[:x] || 0
    @y = options[:y] || 0
    @size = options[:size] || 100
    @angle = Gosu::random(0, 359)
    @rotation_speed = Gosu::random(-1, 1)

    @speed_x = Gosu::random(-2, 2)
    @speed_y = Gosu::random(-2, 2)

    @image = Gosu::Image.new(window, "resources/graphics/meteor_#{size}.png")
  end

  def update
    player = window.player
    distance_to_player = Gosu::distance(self.x, self.y, player.x, player.y)
    player.die if distance_to_player < (self.size + player.size) / 2

    @angle += @rotation_speed

    self.move
    self.keep_on_screen
  end

  def die
    (@explosion = Gosu::Sample.new(self.window, 'resources/sounds/meteor_explosion.wav')).play
    window.remove_actor(self)

    if next_size
      2.times do
        window.spawn_actor(Meteor.new(self.window, :x => self.x, :y => self.y, :size => next_size))
      end
    end
  end

  def next_size
    {
      100 => 70,
      70 => 50,
      50 => 30
    }[self.size]
  end

end

class Projectile < Actor

  def initialize(window, player)
    @window = window
    @x = player.x
    @y = player.y
    @angle = player.angle
    @speed_x = Gosu::offset_x(@angle, 5)
    @speed_y = Gosu::offset_y(@angle, 5)
    @image = Gosu::Image.new(window, 'resources/graphics/projectile.png')
    @life = 100 # In ticks
    @size = 5
  end

  def update
    @life -= 1
    self.die and return if @life < 0

    window.meteors.each do |meteor|
      distance_to_meteor = Gosu::distance(self.x, self.y, meteor.x, meteor.y)
      if distance_to_meteor < meteor.size / 2
        meteor.die
        self.die
        return
      end
    end
    
    self.keep_on_screen
    self.move
  end

  def die
    window.remove_actor(self)
  end

end

class Explosion < Actor

  def initialize(window, player)
    @window = window
    @x = player.x
    @y = player.y
    @explosion = Gosu::Image.load_tiles(window, 'resources/graphics/explosion.png', 48, 48, false)
    @spawn_time = Gosu::milliseconds
    (@sound ||= Gosu::Sample.new(self.window, 'resources/sounds/player_explosion.wav')).play
  end

  def update
    @image_index = (Gosu::milliseconds - @spawn_time) / 100
    self.window.remove_actor(self) if @image_index >= @explosion.length
  end

  def draw
    @explosion[@image_index].draw_rot(self.x, self.y, 0, 0) if @image_index
  end

end

GameWindow.new.show
