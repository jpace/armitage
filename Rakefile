require 'rubygems'
require 'fileutils'

task :default => :buildjrubyjar

$fname    = "armitage.rb"
$clsname  = "ArmitageTestMain.class"

$builddir   = "build"

$metainfdir = "META-INF"
$mfname     = $metainfdir + "/MANIFEST.MF"

$jrubyjar   = "/home/jpace/Downloads/jruby-complete-1.6.3.jar"
$tgtjar     = "armitage.jar"

$rbfiles = %w{ spacebarlistener.rb swingutil.rb csvfile.rb }

def buildfile fname
  File.join($builddir, fname)
end

directory $builddir

directory buildfile($metainfdir)

def copytask fname, deps, taskname
  tgtfile = buildfile(fname)
  file tgtfile => deps do |t|
    cp t.prerequisites.last, t.name
  end
  task taskname => tgtfile
end

def jrubyctask rbfname, taskname
  task taskname do |t|
    sh "jrubyc -t #{$builddir} --javac #{rbfname}"
  end
end

copytask $mfname, [ buildfile($metainfdir), "jar/#{$mfname}" ], :manifest
copytask $tgtjar, [ $jrubyjar ], :tgtjar

def copygroup files, taskname
  files.each do |file|
    tgtfile = buildfile file
    file tgtfile => file do |t|
      cp file, tgtfile
    end
    task taskname => tgtfile
  end
end

copygroup $rbfiles, :rbfiles

jrubyctask $fname, :rbmain

task :jrubyc => $fname do |t|
  sh "jrubyc -t #{$builddir} --javac #{t.prerequisites.last}"
end

copytask $clsname, [ $clsname ], :javaclass
  
task :buildjrubyjar => [ :manifest, :tgtjar, :rbmain, :rbfiles ] do
  Dir.chdir $builddir

  sh "jar ufm #{$tgtjar} #{$mfname} *.class #{$rbfiles.join(' ')}"
end
