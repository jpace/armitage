#!/usr/bin/ruby -w
# -*- ruby -*-

include Java

import java.awt.event.KeyEvent
import java.awt.event.KeyListener


class SpacebarKeyListener 
  include KeyListener

  attr_reader :keytime

  def initialize
    @keytime = nil
  end

  def clear
    @keytime = nil
  end

  def keyTyped e
    # ignore all after the first input ...    
    return if @keytime

    keychar = e.get_key_char

    if keychar == KeyEvent::VK_SPACE
      @keytime = Time.new
    end
  end

  def keyPressed e
  end

  def keyReleased e
  end

end
