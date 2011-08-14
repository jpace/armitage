#!/usr/bin/jruby -w
# -*- ruby -*-

require 'csv'
require 'set'
require 'pathname'
require 'singleton'

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

$testing = true
$param_num = $testing ? 1 : 0   # 0 == actual; 1 == testing

class Array

  def rand
    self[Kernel::rand(size)]
  end
end

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
  OUTER_ITERATIONS_PER_TEST = [22, 4][$param_num]
  INNER_ITERATIONS_PER_TEST = [6, 4][$param_num]

  INPUT_DURATION = [21000, 4000][$param_num] # ms
  
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
    @words = Array.new
    # DATA doesn't seem to work in JRuby -- it produces the source for Set
    @words << "adder"
    @words << "albatross"
    @words << "alcohol"
    @words << "alligator"
    @words << "aluminium"
    @words << "ankle"
    @words << "ant"
    @words << "ape"
    @words << "apple"
    @words << "apricot"
    @words << "asparagus"
    @words << "automobile"
    @words << "axe"
    @words << "bag"
    @words << "bagpipe"
    @words << "ball"
    @words << "balloon"
    @words << "banana"
    @words << "bandage"
    @words << "barn"
    @words << "basin"
    @words << "basket"
    @words << "bath"
    @words << "bayonet"
    @words << "beach"
    @words << "bean"
    @words << "bed"
    @words << "bedroom"
    @words << "beef"
    @words << "beet"
    @words << "beetle"
    @words << "bell"
    @words << "belly"
    @words << "belt"
    @words << "bench"
    @words << "birch"
    @words << "bird"
    @words << "blanket"
    @words << "blood"
    @words << "blouse"
    @words << "bluebell"
    @words << "boat"
    @words << "book"
    @words << "boy"
    @words << "bra"
    @words << "bracelet"
    @words << "bread"
    @words << "brick"
    @words << "bridge"
    @words << "brook"
    @words << "broom"
    @words << "bulldog"
    @words << "butter"
    @words << "button"
    @words << "cabbage"
    @words << "cake"
    @words << "camera"
    @words << "cancer"
    @words << "candy"
    @words << "cannon"
    @words << "canoe"
    @words << "car"
    @words << "cardinal"
    @words << "carnation"
    @words << "carp"
    @words << "carrot"
    @words << "casket"
    @words << "cat"
    @words << "catfish"
    @words << "cattle"
    @words << "cauliflower"
    @words << "cedar"
    @words << "ceiling"
    @words << "cement"
    @words << "cereal"
    @words << "chair"
    @words << "chalk"
    @words << "cherry"
    @words << "chestnut"
    @words << "chicken"
    @words << "chipmunk"
    @words << "cider"
    @words << "cigarette"
    @words << "clarinet"
    @words << "clay"
    @words << "clown"
    @words << "coat"
    @words << "cock"
    @words << "coffee"
    @words << "collar"
    @words << "cork"
    @words << "cotton"
    @words << "cow"
    @words << "crab"
    @words << "crane"
    @words << "cream"
    @words << "cucumber"
    @words << "curler"
    @words << "dad"
    @words << "daisy"
    @words << "dart"
    @words << "deer"
    @words << "dentist"
    @words << "diamond"
    @words << "dog"
    @words << "door"
    @words << "dough"
    @words << "drum"
    @words << "duck"
    @words << "eagle"
    @words << "ear"
    @words << "earthworm"
    @words << "eel"
    @words << "egg"
    @words << "elbow"
    @words << "elephant"
    @words << "emerald"
    @words << "eye"
    @words << "farmyard"
    @words << "feet"
    @words << "film"
    @words << "firewood"
    @words << "flag"
    @words << "flea"
    @words << "forearm"
    @words << "forest"
    @words << "fox"
    @words << "frog"
    @words << "frost"
    @words << "fruit"
    @words << "fudge"
    @words << "fur"
    @words << "furnace"
    @words << "garlic"
    @words << "gin"
    @words << "gingerbread"
    @words << "girl"
    @words << "glass"
    @words << "glove"
    @words << "goat"
    @words << "gondola"
    @words << "gorilla"
    @words << "grape"
    @words << "grasshopper"
    @words << "gravy"
    @words << "gun"
    @words << "haddock"
    @words << "hammer"
    @words << "hand"
    @words << "handkerchief"
    @words << "harbour"
    @words << "hare"
    @words << "harpsichord"
    @words << "hat"
    @words << "hatchet"
    @words << "hawk"
    @words << "hay"
    @words << "head"
    @words << "heart"
    @words << "hedge"
    @words << "helmet"
    @words << "hen"
    @words << "heroin"
    @words << "herring"
    @words << "honey"
    @words << "horn"
    @words << "horse"
    @words << "house"
    @words << "ice"
    @words << "indian"
    @words << "ink"
    @words << "jacket"
    @words << "jaw"
    @words << "jeep"
    @words << "jersey"
    @words << "kennel"
    @words << "kettle"
    @words << "key"
    @words << "kilt"
    @words << "kitten"
    @words << "knife"
    @words << "lamb"
    @words << "lamp"
    @words << "land"
    @words << "lantern"
    @words << "larch"
    @words << "leek"
    @words << "leg"
    @words << "lemon"
    @words << "lemonade"
    @words << "lily"
    @words << "limousine"
    @words << "lion"
    @words << "liquor"
    @words << "liver"
    @words << "macaroni"
    @words << "mackerel"
    @words << "mallet"
    @words << "man"
    @words << "manure"
    @words << "marble"
    @words << "mattress"
    @words << "meal"
    @words << "milk"
    @words << "minnow"
    @words << "mirror"
    @words << "moccasin"
    @words << "monocle"
    @words << "moose"
    @words << "mountain"
    @words << "mouse"
    @words << "mouthpiece"
    @words << "mud"
    @words << "mussel"
    @words << "necklace"
    @words << "needle"
    @words << "newt"
    @words << "nightgown"
    @words << "nightingale"
    @words << "nose"
    @words << "olive"
    @words << "onion"
    @words << "orange"
    @words << "ornament"
    @words << "otter"
    @words << "overcoat"
    @words << "owl"
    @words << "ox"
    @words << "pants"
    @words << "pea"
    @words << "peach"
    @words << "pear"
    @words << "pedal"
    @words << "pencil"
    @words << "penny"
    @words << "phone"
    @words << "piano"
    @words << "pickle"
    @words << "pie"
    @words << "pig"
    @words << "pigeon"
    @words << "pill"
    @words << "pillow"
    @words << "pin"
    @words << "pineapple"
    @words << "pipe"
    @words << "pliers"
    @words << "plum"
    @words << "pond"
    @words << "pony"
    @words << "potato"
    @words << "prune"
    @words << "puddle"
    @words << "puppy"
    @words << "pyramid"
    @words << "quail"
    @words << "quilt"
    @words << "rabbit"
    @words << "radio"
    @words << "rain"
    @words << "rat"
    @words << "ribbon"
    @words << "rice"
    @words << "rifle"
    @words << "robin"
    @words << "rock"
    @words << "rocket"
    @words << "rope"
    @words << "rose"
    @words << "rug"
    @words << "rum"
    @words << "rye"
    @words << "saddle"
    @words << "sandal"
    @words << "sardine"
    @words << "saucer"
    @words << "sauerkraut"
    @words << "saxophone"
    @words << "seed"
    @words << "shark"
    @words << "shawl"
    @words << "shed"
    @words << "sheep"
    @words << "sheepskin"
    @words << "sheet"
    @words << "ship"
    @words << "shirt"
    @words << "shoe"
    @words << "shrimp"
    @words << "skin"
    @words << "skirt"
    @words << "skunk"
    @words << "skylark"
    @words << "skyscraper"
    @words << "sleigh"
    @words << "snake"
    @words << "snow"
    @words << "soda"
    @words << "sofa"
    @words << "soup"
    @words << "sparrow"
    @words << "spider"
    @words << "spoon"
    @words << "squirrel"
    @words << "statue"
    @words << "steak"
    @words << "stew"
    @words << "stick"
    @words << "stoat"
    @words << "stomach"
    @words << "stone"
    @words << "stork"
    @words << "straw"
    @words << "strawberry"
    @words << "sugar"
    @words << "sun"
    @words << "sycamore"
    @words << "table"
    @words << "tail"
    @words << "tangerine"
    @words << "tea"
    @words << "teeth"
    @words << "telephone"
    @words << "tent"
    @words << "thermometer"
    @words << "thistle"
    @words << "thread"
    @words << "thumb"
    @words << "tiger"
    @words << "tobacco"
    @words << "toe"
    @words << "tomato"
    @words << "tongue"
    @words << "tooth"
    @words << "tornado"
    @words << "tortoise"
    @words << "trapeze"
    @words << "tree"
    @words << "trombone"
    @words << "trout"
    @words << "trumpet"
    @words << "tulip"
    @words << "turpentine"
    @words << "turtle"
    @words << "typewriter"
    @words << "umbrella"
    @words << "van"
    @words << "vegetable"
    @words << "vine"
    @words << "vinegar"
    @words << "violin"
    @words << "walnut"
    @words << "walrus"
    @words << "water"
    @words << "weed"
    @words << "whale"
    @words << "whiskey"
    @words << "wig"
    @words << "window"
    @words << "wine"
    @words << "wood"
    @words << "wool"
    @words << "worm"
    @words << "wren"
    @words << "yacht"
  end

  def get_random
    @words.rand
  end

end


class Equation
  attr_reader :formula, :result

  def initialize(formula, result = nil)
    @formula = formula.to_s
    @result  = result || @formula.to_i
  end

  java_signature 'String toString()'
  def to_s
    "#{@formula} => #{@result}"
  end
end

class EquationGenerator
  include Singleton
  
  def factors num
    if num == 1
      []
    else
      sq = Math.sqrt(num).floor
      possibles = [ 2 ] + (3 ..sq).step(2).collect { |n| n }
      possibles.each do |n|
        if num % n == 0
          return [ n ] + factors(num / n)
        end
      end
      [ num ]
    end
  end

  def exec_rand *blocks
    bidx = rand(blocks.size)
    blk  = blocks[bidx]
    blk.call
  end

  def create_formula(lo, hi)
    mult_gen = Proc.new do
      result = rand_bounded(lo, hi)
      facs   = factors result
      lhs    = facs.rand
      rhs    = result / lhs
      
      Equation.new "#{lhs} * #{rhs}", lhs * rhs
    end

    div_gen = Proc.new do
      lhs  = rand_bounded(lo, hi)
      facs = factors lhs
      while facs.size == 1
        lhs  = rand_bounded(lo, hi)
        facs = factors lhs
      end

      rhs = facs.rand
      Equation.new "#{lhs} / #{rhs}", lhs / rhs
    end

    exec_rand mult_gen, div_gen
  end

  def rand_bounded(min, max)
    min + rand(max - min)
  end

  def next
    num_plus_formula = Proc.new do
      lnum  = rand_bounded(2, 5)
      rform = create_formula(2, 12)
      Equation.new "#{lnum} + (#{rform.formula})", lnum + rform.result
    end
    
    num_minus_formula = Proc.new do
      lnum = rand_bounded(5, 13)
      rform = create_formula(2, lnum)
      Equation.new "#{lnum} - (#{rform.formula})", lnum - rform.result
    end

    formula_plus_num = Proc.new do
      lform = create_formula(2, 12)
      rnum = rand_bounded(2, 5)
      Equation.new "(#{lform.formula}) + #{rnum}", lform.result + rnum
    end
    
    formula_minus_num = Proc.new do
      lform = create_formula(5, 12)
      rnum = rand_bounded(1, lform.result + 1)
      Equation.new "(#{lform.formula}) - #{rnum}", lform.result - rnum
    end
    
    exec_rand num_plus_formula, num_minus_formula, formula_plus_num, formula_minus_num
  end
end


class EquationSet
  include Singleton

  def initialize
    @equations = Hash.new

    eg = EquationGenerator.instance

    10.times do
      eqn = eg.next
      @equations[eqn] = true
    end

    10.times do
      eqn = eg.next
      badeqn = Equation.new eqn.formula, eqn.result + (rand(2) == 0 ? 1 : -1) * (1 + rand(3))
      @equations[badeqn] = false
    end
  end

  def is_correct eqn
    @equations[eqn]
  end

  def get_random
    @equations.keys.rand
  end
end


class EqnWordRenderer < LineDrawer
  include ArmitageTestConstants

  attr_accessor :length_in_mm

  def initialize test
    @test = test

    @current_word = ConcreteWordSet.instance.get_random
    @current_eqn  = EquationSet.instance.get_random
  end

  def is_correct
    EquationSet.instance.is_correct @current_eqn
  end

  def render g, dim
    return unless @test.show

    g.color = FOREGROUND_COLOR

    draw_text g, dim, [ @current_word, @current_eqn.formula + " = " + @current_eqn.result.to_s ]
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

class WordEntryDialog
  include ArmitageTestConstants

  attr_reader :value

  def initialize panel
    @indlg = nil
    @value = nil

    java.lang.Thread.new(self).start

    first_char = rand(2) == 0

    @indlg = InputDialog.new panel, "Enter the " + (first_char ? "first" : "last") + " character of each word:", "Query"
    @indlg.show

    if @indlg
      @value = @indlg.value
      @indlg.dispose
    end
  end

  def run
    until @indlg
      java.lang.Thread.sleep 100
    end

    java.lang.Thread.sleep INPUT_DURATION

    @indlg.dispose
    @indlg = nil
  end
end


class ArmitageTestRunner
  include ArmitageTestConstants

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
    @inner_iterations.times do |iidx|
      run_inner_iteration iidx
    end

    wed = WordEntryDialog.new @mainpanel
    @inchars = wed.value
  end

  def run_inner_iteration num
    ewr = EqnWordRenderer.new self

    starttime = Time.now
    @key_timer.clear
    
    @show = true

    @mainpanel.renderer = ewr

    repaint
    java.lang.Thread.sleep DISPLAY_DURATION

    @show = false
    
    repaint

    endtime = Time.now

    duration = endtime - starttime
    
    sleep_duration = (ArmitageTestConstants::DISPLAY_DURATION - duration).to_i

    java.lang.Thread.sleep INTERVAL_DURATION

    # get it here, so subsequent calls don't let one "leak" in
    keytime = @key_timer.keytime
    
    answered = !keytime.nil?

    response_time = answered ? keytime.to_f - starttime.to_f : -1.0

    is_correct = answered == ewr.is_correct

    if !is_correct
      @mainpanel.background_color = ArmitageTestConstants::BACKGROUND_COLOR_FLASH
      repaint
    end

    java.lang.Thread.sleep 250
    
    if !is_correct
      @mainpanel.background_color = ArmitageTestConstants::BACKGROUND_COLOR
      repaint      
    end

    response = [ @user_id, response_time, answered, ewr.is_correct, is_correct ]

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
      appname = "Armitage Psychological Working Memory Test"
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
