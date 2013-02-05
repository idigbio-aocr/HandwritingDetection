#!/usr/bin/env ruby

pattern = ARGV[0]

filenames = Dir.glob(pattern)

out_fn = Time.new.to_s.gsub(/\W/, '_')
out_fn = 'hw_sort+' + out_fn + '.csv'
outfile = File.open(out_fn, 'w')
filenames.each do |fn|
  print "\nContents of #{fn}:\n"
  
  print File.read(fn)
  print "\n\nWhat kind of file is this\n(1=typed,2=handwritten,3=unsure)\n> "
  $stdout.flush
  value = $stdin.gets.chomp
  print "\nYou said #{value}!\n"
  outfile.print("\"#{fn}\",#{value}\n")  
end

outfile.close