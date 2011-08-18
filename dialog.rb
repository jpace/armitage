#!/usr/bin/ruby -w
# -*- ruby -*-

include Java

import javax.swing.JOptionPane
import javax.swing.JRootPane


class InputDialog

  def initialize parent, message, title
    # from javax.swing.JOptionPane
    
    @pane = JOptionPane.new(message, JOptionPane::PLAIN_MESSAGE, JOptionPane::OK_CANCEL_OPTION)

    @pane.wants_input = true
    @pane.selection_values = nil
    @pane.initial_selection_value = nil
    @pane.component_orientation = parent.component_orientation

    @dialog = @pane.create_dialog(parent, title, javax.swing.JRootPane::PLAIN_DIALOG)
                               
    @pane.select_initial_value
  end

  def show
    @dialog.show
  end

  def dispose
    @dialog.dispose
  end

  def value
    @pane.input_value
  end
end
