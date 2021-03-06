#!/usr/bin/jruby -w
# -*- ruby -*-

require 'set'
require 'pathname'
require 'singleton'

require 'csvfile'
require 'dialog'
require 'drawer'
require 'equation'
require 'panel'
require 'spacebarlistener'
require 'swingutil'
require 'testframe'

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

$testing = false
$param_num = $testing ? 1 : 0   # 0 == actual; 1 == testing

class Array

  def rand
    self[Kernel::rand(size)]
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

  INPUT_DURATION = [21000, 8000][$param_num] # ms
  
  BACKGROUND_COLOR = Color.new 250, 250, 250

  BACKGROUND_COLOR_FLASH = Color.new 250, 0, 0
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


class EquationSet
  include Singleton

  NUMBER_OF_EQUATIONS = 20

  def initialize
    @equations = Hash.new

    eg = EquationGenerator.instance

    NUMBER_OF_EQUATIONS.times do
      goodeqn = eg.next
      @equations[goodeqn] = true
      
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


class ArmitageLineDrawer < LineDrawer
  include ArmitageTestConstants

  def initialize
    super(FOREGROUND_COLOR, LINE_THICKNESS)
  end
end


class EqnWordRenderer < ArmitageLineDrawer
  include ArmitageTestConstants

  attr_accessor :length_in_mm, :current_word

  def initialize test
    super()
    
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


class TextRenderer < ArmitageLineDrawer

  def render g, dim
    draw_text g, dim, text
  end

end


class IntroRenderer < TextRenderer

  attr_reader :text
  
  def initialize
    @text = Array.new
    
    @text << "For each of the following screens,"
    @text << "press the spacebar when the calculation is correct."
    @text << ""
    @text << "For example:"
    @text << "window"
    @text << "8 + (2 - 1) = 9"
    @text << ""
    @text << "A word will be displayed above the equation, and that"
    @text << "word should be remembered for later."

    super()
  end

end


class OutroRenderer < TextRenderer

  attr_reader :text  

  def initialize
    @text = Array.new
    
    @text << "End of test."
    @text << ""

    super()
  end

end


class WordEntryDialog
  include ArmitageTestConstants

  attr_reader :value

  def initialize panel, first_char
    @indlg = nil
    @value = nil

    java.lang.Thread.new(self).start

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

    @eqn_responses = Array.new

    @word_responses = Array.new

    java.lang.Thread.new(self).start
  end

  def repaint
    @mainpanel.repaint
  end

  def run_outer_iteration num
    @first_char  = rand(2) == 0
    puts "@first_char: #{@first_char}"
    @shown_chars = ""

    @inner_iterations.times do |iidx|
      run_inner_iteration iidx
    end
      
    wed = WordEntryDialog.new @mainpanel, @first_char
    @inchars = wed.value

    puts "@inchars: #{@inchars}"
    puts "@shown_chars: #{@shown_chars}"

    word_response = [ @user_id, @shown_chars, @inchars, @shown_chars == @inchars ]

    @word_responses << word_response
  end

  def run_inner_iteration num
    ewr = EqnWordRenderer.new self

    char_idx = @first_char ? 0 : -1

    @shown_chars << ewr.current_word[char_idx].chr

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

    eqn_response_time = answered ? keytime.to_f - starttime.to_f : -1.0

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

    eqn_response = [ @user_id, eqn_response_time, answered, ewr.is_correct, is_correct ]

    puts "eqn_response: #{eqn_response.inspect}"
    
    @eqn_responses << eqn_response

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
    @mainpanel.renderer = OutroRenderer.new

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

  def write_response_file fname, header_fields, responses
    resfile = CSVFile.new(fname, header_fields)
    
    resfile.addlines responses
    resfile.write
  end

  def write_eqn_responses
    header_fields = [ "userid", "duration", "answered", "is_correct", "accurate" ]

    write_response_file 'armitage_eqns.csv', header_fields, @eqn_responses
  end

  def write_word_responses
    header_fields = [ "userid", "actual", "response", "is_correct" ]
    
    write_response_file 'armitage_words.csv', header_fields, @word_responses
  end

  def write_responses
    write_eqn_responses
    write_word_responses
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
    @mainpanel.renderer = IntroRenderer.new
    @mainpanel.repaint

    java.lang.Thread.sleep ArmitageTestConstants::INTRO_DURATION
  end
end


class ArmitageTestFrame < TestFrame

  def initialize
    super ArmitageTestConstants::APP_NAME, ArmitageTestConstants::BACKGROUND_COLOR
  end

  def run_test
    ArmitageTest.new @panel
  end

  def run_intro
    ArmitageTestIntro.new @panel
  end

  def run_demo
    ArmitageTestDemo.new @panel
  end

  def get_about_text
    appname = "Armitage Psychological Working Memory Test"
    author  = "Jeff Pace (jeugenepace&#64;gmail&#46;com)"
    website = "http://www.incava.org"
    github  = "https://github.com/jeugenepace"
    text    = "<html>"
    text    << appname
    text    << "<hr>"
    text    << "Written by #{author}" << "<br>"
    text    << "&nbsp;&nbsp;&nbsp #{website}" << "<br>"
    text    << "&nbsp;&nbsp;&nbsp #{github}" << "<br>"
    text    << "</html>"
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
