#!/usr/bin/ruby -w
# -*- ruby -*-

require 'singleton'

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
