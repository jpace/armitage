#!/usr/bin/jruby -w
# -*- ruby -*-

include Java

import java.awt.Toolkit

module SwingUtil

  def self.included base
    @@pixels_per_mm = Toolkit.default_toolkit.screen_resolution.to_f / 25.4
  end

  def mm_to_pixels length_in_mm
    length_in_mm * @@pixels_per_mm
  end

end
