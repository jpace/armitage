#!/usr/bin/ruby -w
# -*- ruby -*-

require 'swingutil'

include Java

import java.awt.RenderingHints
import javax.swing.JPanel


class MainPanel < JPanel
  include SwingUtil

  attr_accessor :renderer, :background_color
  
  def initialize background_color
    super()

    @renderer = nil
    @background_color = background_color
    @rh = RenderingHints.new RenderingHints::KEY_ANTIALIASING, RenderingHints::VALUE_ANTIALIAS_ON
    @rh.put RenderingHints::KEY_RENDERING, RenderingHints::VALUE_RENDER_QUALITY
  end

  def paintComponent g
    super

    g.background = @background_color

    g.rendering_hints = @rh
    
    dim = size

    clear_screen g, dim

    if @renderer
      @renderer.render g, dim
    end
  end

  def clear_screen g, dim
    g.clear_rect 0, 0, dim.width, dim.height
  end

end
