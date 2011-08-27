#!/usr/bin/jruby -w
# -*- ruby -*-

require 'set'
require 'pathname'

require 'csvfile'
require 'drawer'
require 'panel'
require 'spacebarlistener'
require 'swingutil'

include Java

import java.awt.Color
import java.awt.RenderingHints
import java.awt.Toolkit
import java.awt.event.KeyEvent
import java.awt.event.KeyListener
import java.awt.geom.Ellipse2D
import javax.swing.JButton
import javax.swing.JFrame
import javax.swing.JMenu
import javax.swing.JMenuBar
import javax.swing.JMenuItem
import javax.swing.JOptionPane
import javax.swing.JPanel

class TestFrame < JFrame

  def initialize appname, background_color
    super appname

    menubar = JMenuBar.new

    test_menu = JMenu.new "Test"
    test_menu.mnemonic = KeyEvent::VK_T

    item_new = JMenuItem.new "New"
    item_new.mnemonic = KeyEvent::VK_N
    item_new.tool_tip_text = "Run a new test"
    
    item_new.add_action_listener do |e|
      run_test
      @panel.grab_focus
    end

    test_menu.add item_new

    item_intro = JMenuItem.new "Intro"
    item_intro.mnemonic = KeyEvent::VK_I
    item_intro.tool_tip_text = "Run the intro"
    
    item_intro.add_action_listener do |e|
      run_intro
      @panel.grab_focus
    end

    test_menu.add item_intro

    item_demo = JMenuItem.new "Demo"
    item_demo.mnemonic = KeyEvent::VK_D
    item_demo.tool_tip_text = "Run the demo"
    
    item_demo.add_action_listener do |e|
      run_demo
      @panel.grab_focus
    end

    test_menu.add item_demo

    item_exit = JMenuItem.new "Exit"
    item_exit.add_action_listener do |e|
      dialog = javax.swing.JDialog.new

      ok = JOptionPane.show_confirm_dialog self, "Are you sure you want to quit?", "Quit?", JOptionPane::YES_NO_OPTION
      
      if ok == 0
        java.lang.System.exit 0
      end
    end
    
    item_exit.mnemonic = KeyEvent::VK_X
    item_exit.tool_tip_text = "Exit application"

    test_menu.add item_exit

    menubar.add test_menu

    help_menu = JMenu.new "Help"
    help_menu.mnemonic = KeyEvent::VK_H

    item_about = JMenuItem.new "About"
    item_about.mnemonic = KeyEvent::VK_A
    item_about.tool_tip_text = "Show information about the program"    

    item_about.add_action_listener do |e|
      about_text = get_about_text
      JOptionPane.show_message_dialog self, about_text, "About", JOptionPane::OK_OPTION
    end
      
    help_menu.add item_about

    menubar.add help_menu

    set_jmenu_bar menubar  

    # this works fine on Linux with Java 1.6, but not Windows with any version,
    # or Linux with Java 1.5:
    # set_extended_state JFrame::MAXIMIZED_BOTH
    # set_undecorated true
    
    set_default_close_operation JFrame::EXIT_ON_CLOSE
    set_location_relative_to nil
    get_content_pane.layout = java.awt.BorderLayout.new

    @panel = MainPanel.new background_color

    get_content_pane.add @panel, java.awt.BorderLayout::CENTER

    @panel.layout = nil

    @panel.request_focus_in_window

    pack
    set_visible true

    move(0, 0)
    resize Toolkit.default_toolkit.screen_size
  end

  def run_test
    raise "ERROR: run_test not implemented"
  end

  def run_intro
    raise "ERROR: run_intro not implemented"
  end

  def run_demo
    raise "ERROR: run_demo not implemented"
  end

  def get_about_text
    raise "ERROR: get_about_text not implemented"
  end
  
end
