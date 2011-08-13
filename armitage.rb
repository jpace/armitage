#!/usr/bin/jruby -w
# -*- ruby -*-

require 'csv'
require 'set'
require 'pathname'

require 'rubygems'
require 'riel'

Log.level = Log::DEBUG

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

Log.level = Log::DEBUG

$testing = true
$param_num = $testing ? 1 : 0   # 0 == actual; 1 == testing

module SwingUtil

  def self.included base
    @@pixels_per_mm = Toolkit.default_toolkit.screen_resolution.to_f / 25.4
  end

  def mm_to_pixels length_in_mm
    length_in_mm * @@pixels_per_mm
  end

end


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


class ArmitageTestResultsFile 

  CSV_HEADER_FIELDS = [ "userid", "duration", "answered", "is_correct", "accurate" ]

  CSV_FILE_NAME = 'armitage.csv'

  def self.home_directory
    home = ENV['HOME']
    unless home
      home = (ENV['HOMEDRIVE'] || "") + (ENV['HOMEPATH'] || "")
    end
    
    homedir = ENV['HOME'] || (ENV['HOMEDRIVE'] + ENV['HOMEPATH'])
    Pathname.new(homedir)
  end

  def initialize
    @csv_file = self.class.home_directory + CSV_FILE_NAME
    
    @csv_lines = @csv_file.exist? ? CSV.read(@csv_file.to_s) : [ CSV_HEADER_FIELDS ]
  end

  def addlines lines
    @csv_lines.concat lines
  end

  def write
    @csv_lines.each do |line|
      puts line
    end

    CSV.open @csv_file.to_s, 'w' do |csv|
      @csv_lines.each do |line|
        csv << line
      end
    end
  end
end

module ArmitageTestConstants

  APP_NAME = "Armitage"
  
  DISPLAY_DURATION   = [1800, 1800][$param_num] # ms
  INTERVAL_DURATION  = [700,   700][$param_num] # ms
  
  LINE_THICKNESS = 4

  FOREGROUND_COLOR = Color.new 50, 50, 50

  INTRO_DURATION = 5000         # ms

  # $$$ need confirmation about how many iterations to run here:
  OUTER_ITERATIONS_PER_TEST = [22, 6][$param_num]
  INNER_ITERATIONS_PER_TEST = [6, 4][$param_num]
  
  BACKGROUND_COLOR = Color.new 250, 250, 250

  BACKGROUND_COLOR_FLASH = Color.new 250, 0, 0

end


class MainPanel < JPanel
  include SwingUtil

  attr_accessor :renderer, :background_color
  
  def initialize
    super()

    @renderer = nil
    @background_color = ArmitageTestConstants::BACKGROUND_COLOR
  end

  def paintComponent g
    super

    g.background = @background_color

    rh = RenderingHints.new RenderingHints::KEY_ANTIALIASING, RenderingHints::VALUE_ANTIALIAS_ON
    
    rh.put RenderingHints::KEY_RENDERING, RenderingHints::VALUE_RENDER_QUALITY
    
    g.rendering_hints = rh

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


class LineDrawer
  include SwingUtil

  def draw_centered_line gdimary, y, length_in_mm
    g   = gdimary[0]
    dim = gdimary[1]
  
    g.color = ArmitageTestConstants::FOREGROUND_COLOR
    
    len   = mm_to_pixels length_in_mm
    ctr_x = dim.width  / 2
    x     = ctr_x - len / 2

    g.fill_rect x, y, len, ArmitageTestConstants::LINE_THICKNESS
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


class ConcreteWordSet
  include Singleton

  def initialize
    # http://www.writing.com/main/view_item/item_id/1757079-Concrete-Nouns-List
    @words = %w{ window chair table lamp desk pencil pen cow dog cat mouse }
  end

  def get_random
    @words.rand
  end

end


class EquationSet
  include Singleton, Loggable

  def initialize
    @equations = Hash.new
    correct_equations = Array.new

    correct_equations << "4 + (9 / 3) = 7 yes"
    correct_equations << "(4 x 2) - 6 = 2 yes"
    correct_equations << "7 - (8 / 2) = 3 yes"
    correct_equations << "(6 / 3) + 4 = 6 yes"
    correct_equations << "(8 / 4) + 3 = 5 yes"
    correct_equations << "(3 * 4) - 4 = 8 yes"
    correct_equations << "(2 * 3) - 1 = 5 yes"
    correct_equations << "(6 / 3) + 4 = 6 yes"

    incorrect_equations = Array.new
    incorrect_equations << "(9 / 3) - 1 = 4 no"
    incorrect_equations << "4 + (2 * 2) = 6 no"
    incorrect_equations << "4 - (3 / 1) = 3 no"
    incorrect_equations << "6 + (8 / 4) = 10 no"
    incorrect_equations << "(4 * 2) - 3 = 1 no"
    incorrect_equations << "2 * (4 - 3) = 4 no"
    incorrect_equations << "4 + (3 * 2) = 8 no"
    incorrect_equations << "8 - (4 - 2) = 8 no"

    correct_equations.each do |eqn|
      @equations[eqn] = true
    end

    incorrect_equations.each do |eqn|
      @equations[eqn] = false
    end
  end

  def correct? eqn
    info "equations[#{eqn}]: #{@equations[eqn]}".cyan
    @equations[eqn]
  end

  def get_random
    @equations.keys.rand
  end
end


class EqnWordRenderer < LineDrawer
  include ArmitageTestConstants, Loggable

  attr_accessor :length_in_mm

  def initialize test
    @test = test

    @current_word = ConcreteWordSet.instance.get_random
    @current_eqn  = EquationSet.instance.get_random

    stack "@current_eqn: #{@current_eqn}".cyan
  end

  def correct?
    EquationSet.instance.correct? @current_eqn
  end

  def render g, dim
    return unless @test.show

    g.color = FOREGROUND_COLOR

    draw_text g, dim, [ @current_word, @current_eqn ]
  end

end


class IntroRenderer < LineDrawer

  def initialize test
    @text = Array.new
    
    @text << "For each of the following screens,"
    @text << "press the spacebar when the calculation is correct."
    @text << ""
    @text << "For example:"
    @text << "window"
    @text << "8 + (2 - 1) = 9"
  end

  def render g, dim
    draw_text g, dim, @text
  end

end


class OutroRenderer < LineDrawer

  def initialize test
    @text = Array.new
    
    @text << "End of test."
    @text << ""
  end

  def render g, dim
    draw_text g, dim, @text
  end

end


class InputDialog
  include Loggable

  def initialize parent, message, title
    # from javax.swing.JOptionPane
    
    pane = JOptionPane.new(message, JOptionPane::PLAIN_MESSAGE, JOptionPane::OK_CANCEL_OPTION)
    info "pane: #{pane}"

    pane.setWantsInput(true)
    pane.setSelectionValues(nil)
    pane.setInitialSelectionValue(nil)
    pane.setComponentOrientation(parent.getComponentOrientation())

    dialog = pane.createDialog(parent, title, javax.swing.JRootPane::PLAIN_DIALOG)
                               
    pane.selectInitialValue()
    dialog.show
    dialog.dispose

    value = pane.getInputValue()

    info "value: #{value}"
  end
end

class WordEntryDialog
  include Loggable

  def initialize panel
    @window = find_window panel

    # java.lang.Thread.new(self).start
    info "running!".yellow

    InputDialog.new panel, "type the word", "type!"

    # ok = JOptionPane.show_input_dialog panel, "Now type the word", "Type!", JOptionPane::PLAIN_MESSAGE

    info "done running".yellow
  end

  def find_window comp
    while comp
      cls = comp.getClass()
      while cls
        if cls.getName() == "java.awt.Window"
          return comp
        else
          cls = cls.getSuperclass()
        end
      end
      comp = comp.getParent()
    end
    nil
  end

  def run
    info "sleeping ..."

    dlg = nil

    until dlg
      windows = @window.getOwnedWindows()
      info "windows: #{windows}"

      windows.each do |w|
        info "w: #{w}".blue
      end
      
      windows.each do |w|
        info "w: #{w}"
        if w.getClass().getName() == "javax.swing.JDialog"
          info "w: #{w}".green
          dlg = w
        end
      end
    end

    info "dlg: #{dlg}"

    java.lang.Thread.sleep 2000
    info "done sleeping"

    dlg.dispose
  end
end


class ArmitageTestRunner
  include ArmitageTestConstants, Loggable

  attr_reader :show

  def initialize mainpanel, outer_iterations, inner_iterations
    @mainpanel = mainpanel
    @outer_iterations = outer_iterations
    @inner_iterations = inner_iterations

    @key_timer = SpacebarKeyListener.new

    @mainpanel.add_key_listener @key_timer

    @show = true

    @responses = Array.new

    java.lang.Thread.new(self).start
  end

  def repaint
    @mainpanel.repaint
  end

  def run_outer_iteration num
    if false
      @inner_iterations.times do |iidx|
        info "iidx: #{iidx}"
        
        run_inner_iteration iidx
      end    
    end
    # give them x seconds

    WordEntryDialog.new @mainpanel

  end

  def run_inner_iteration num
    info "num: #{num}"
    ewr = EqnWordRenderer.new self

    starttime = Time.now
    info "starting: #{starttime.to_f}"
    @key_timer.clear
    
    info "num: #{num}"

    @show = true

    @mainpanel.renderer = ewr

    repaint
    java.lang.Thread.sleep DISPLAY_DURATION

    @show = false
    
    info "pausing: #{Time.new.to_f}"

    repaint

    endtime = Time.now

    duration = endtime - starttime
    
    sleep_duration = (ArmitageTestConstants::DISPLAY_DURATION - duration).to_i

    java.lang.Thread.sleep INTERVAL_DURATION

    info "@key_timer: #{@key_timer}"

    # get it here, so subsequent calls don't let one "leak" in
    keytime = @key_timer.keytime
    
    answered = !keytime.nil?

    response_time = answered ? keytime.to_f - starttime.to_f : -1.0

    info "response_time: #{response_time}"
    info "answered: #{answered}"
    info "ewr.correct?: #{ewr.correct?}"

    is_correct = answered == ewr.correct?
    info "is_correct: #{is_correct}".red

    if !is_correct
      @mainpanel.background_color = ArmitageTestConstants::BACKGROUND_COLOR_FLASH
      repaint
    end

    java.lang.Thread.sleep 250
    
    if !is_correct
      @mainpanel.background_color = ArmitageTestConstants::BACKGROUND_COLOR
      repaint      
    end

    response = [ @user_id, response_time, answered, ewr.correct?, is_correct ]

    puts "response: #{response.inspect}"
    
    @responses << response

    # puts "done: #{Time.new.to_f}"
  end

  def run_test
    @show = false

    java.lang.Thread.sleep 1000

    @outer_iterations.times do |num|
      run_outer_iteration num
    end
  end

  def show_outro
    @mainpanel.renderer = OutroRenderer.new self

    repaint
  end

  def run
    @user_id = Time.new.to_f
    
    puts "#{Time.new}: running"

    run_test

    show_outro
  end
end


class ArmitageTest < ArmitageTestRunner

  def initialize mainpanel
    super(mainpanel, ArmitageTestConstants::OUTER_ITERATIONS_PER_TEST, ArmitageTestConstants::INNER_ITERATIONS_PER_TEST)
  end

  def write_responses
    resfile = ArmitageTestResultsFile.new

    resfile.addlines @responses

    resfile.write
  end

  def run
    super

    write_responses
  end
end


class ArmitageTestDemo < ArmitageTestRunner

  def initialize mainpanel
    super(mainpanel, 1, 3)
  end

end


class ArmitageTestIntro

  def initialize mainpanel
    @mainpanel = mainpanel

    java.lang.Thread.new(self).start
  end

  def run
    @mainpanel.renderer = IntroRenderer.new self
    @mainpanel.repaint

    java.lang.Thread.sleep ArmitageTestConstants::INTRO_DURATION
  end
end


class ArmitageTestFrame < JFrame

  def initialize
    super ArmitageTestConstants::APP_NAME

    menubar = JMenuBar.new

    test_menu = JMenu.new "Test"
    test_menu.mnemonic = KeyEvent::VK_T

    item_new = JMenuItem.new "New"
    item_new.mnemonic = KeyEvent::VK_N
    item_new.tool_tip_text = "Run a new test"
    
    item_new.add_action_listener do |e|
      ArmitageTest.new @panel
      @panel.grab_focus
    end

    test_menu.add item_new

    item_intro = JMenuItem.new "Intro"
    item_intro.mnemonic = KeyEvent::VK_I
    item_intro.tool_tip_text = "Run the intro"
    
    item_intro.add_action_listener do |e|
      ArmitageTestIntro.new(@panel)
      @panel.grab_focus
    end

    test_menu.add item_intro

    item_demo = JMenuItem.new "Demo"
    item_demo.mnemonic = KeyEvent::VK_D
    item_demo.tool_tip_text = "Run the demo"
    
    item_demo.add_action_listener do |e|
      ArmitageTestDemo.new(@panel)
      @panel.grab_focus
    end

    test_menu.add item_demo

    item_exit = JMenuItem.new "Exit"
    item_exit.add_action_listener do |e|
      dialog = javax.swing.JDialog.new

      ok = JOptionPane.show_confirm_dialog self, "Are you sure you want to quit?", "Quit?", JOptionPane::YES_NO_OPTION
      
      puts "ok? #{ok}"
      if ok == 0
        java.lang.System.exit 0
      else
        puts "not yet quitting!"
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
      appname = "Armitage Psychological Vigilance Test"
      author  = "Jeff Pace (jeugenepace&#64;gmail&#46;com)"
      website = "http://www.incava.org"
      github  = "https://github.com/jeugenepace"
      msg     = "<html>"
      msg     << appname
      msg     << "<hr>"
      msg     << "Written by #{author}" << "<br>"
      msg     << "&nbsp;&nbsp;&nbsp #{website}" << "<br>"
      msg     << "&nbsp;&nbsp;&nbsp #{github}" << "<br>"
      msg     << "</html>"
      JOptionPane.show_message_dialog self, msg, "About", JOptionPane::OK_OPTION
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

    @panel = MainPanel.new

    get_content_pane.add @panel, java.awt.BorderLayout::CENTER

    @panel.layout = nil

    @panel.request_focus_in_window

    pack
    set_visible true

    move(0, 0)
    resize Toolkit.default_toolkit.screen_size
  end
end

class ArmitageTestMain

  java_signature 'void main(String[])'
  def self.main args
    puts "starting main"

    ArmitageTestFrame.new
  end
end


if __FILE__ == $0
  ArmitageTestMain.main Array.new
end
