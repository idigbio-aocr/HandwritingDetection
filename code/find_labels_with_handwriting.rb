#!/usr/bin/env ruby
# encoding: UTF-8
require 'pp'

GARBAGE_REGEXEN = {
  'Four Dots' => /\.\.\.\./,
  'Five Non-Alphanumerics' => /\W\W\W\W\W/,
  'Isolated Euro Sign' => /\S€\D/,
  'Double "Low-Nine" Quotes' => /„/,
  'Anomalous Pound Sign' => /£\D/,
  'Caret' => /\^/,
  'Guillemets' => /[«»]/,
  'Double Slashes and Pipes' => /(\\\/)|(\/\\)|([\/\\]\||\|[\/\\])/,
  'Bizarre Capitalization' => /([A-Z][A-Z][a-z][a-z])|([a-z][a-z][A-Z][A-Z])|([A-Z][a-z][A-Z])/,
  'Mixed Alphanumerics' => /(\w[^\s\w]\w).*(\w[^\s\w]\w)/
}


pattern = ARGV[0]

filenames = Dir.glob(pattern)

#out_fn = Time.new.to_s.gsub(/\W/, '_')
#out_fn = 'hw_files+' + out_fn + '.txt'
#outfile = File.open(out_fn, 'w')
file_scores = {}
filenames.each do |fn|
#  print "\nInspecting #{fn}\n"
  score = 0 
  File.readlines(fn).each do |line|
    GARBAGE_REGEXEN.keys.each do |name|
      if GARBAGE_REGEXEN[name] =~ line
        print "#{fn}: Found #{name} in #{line}"
        score += 1
      end
    end
    file_scores[fn]=score    
  end
end
pp file_scores

file_scores.keys.each do |fn|
  if file_scores[fn] == 0
    print "cat #{fn}\n"
    print "od -c #{fn}\n"
    
  end
end

#outfile.close