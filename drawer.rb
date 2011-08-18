#!/usr/bin/ruby -w
# -*- ruby -*-

require 'swingutil'

include Java


class LineDrawer
  include SwingUtil

  def initialize foreground_color, line_thickness
    @foreground_color = foreground_color
    @line_thickness = line_thickness
  end

  def draw_centered_line gdimary, y, length_in_mm
    g   = gdimary[0]
    dim = gdimary[1]
  
    g.color = @foreground_color
    
    len   = mm_to_pixels length_in_mm
    ctr_x = dim.width  / 2
    x     = ctr_x - len / 2

    g.fill_rect x, y, len, @line_thickness
  end

  def draw_text g, dim, text
    g.font = java.awt.Font.new "Times New Roman", java.awt.Font::PLAIN, 18

    ctr_x = dim.width / 2
    ctr_y = dim.height / 2

    x = (ctr_x * 0.80).to_i
    y = (ctr_y * 0.60).to_i
    
    text.each_with_index do |line, idx|
      g.draw_string line, x, y + (idx * 30)
    end
  end

end
