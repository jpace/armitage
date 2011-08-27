#!/usr/bin/jruby -w
# -*- ruby -*-

require 'csv'


# CSV file in home directory
class CSVFile 

  def self.home_directory
    home = ENV['HOME']
    unless home
      home = (ENV['HOMEDRIVE'] || "") + (ENV['HOMEPATH'] || "")
    end
    
    homedir = ENV['HOME'] || (ENV['HOMEDRIVE'] + ENV['HOMEPATH'])
    Pathname.new(homedir)
  end

  def initialize fname, header_fields
    @csv_file = self.class.home_directory + fname
    
    @csv_lines = @csv_file.exist? ? CSV.read(@csv_file.to_s) : [ header_fields ]
  end

  def addlines lines
    @csv_lines.concat lines
  end

  def write
    if false
      @csv_lines.each do |line|
        puts line
      end
    end

    CSV.open @csv_file.to_s, 'w' do |csv|
      @csv_lines.each do |line|
        csv << line
      end
    end
  end
end
