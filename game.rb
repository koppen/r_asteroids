#!/usr/bin/env ruby

require 'rubygems'
require 'gosu'

class GameWindow < Gosu::Window

  def initialize
    super(800, 600, false)
  end
  
  def update
    # Quit?
    exit if button_down? Gosu::Button::KbEscape
  end
  
  def draw
  end

end

GameWindow.new.show
