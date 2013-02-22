#!/usr/bin/env ruby
# encoding: UTF-8
require 'pp'
require 'csv'


GARBAGE_REGEXEN = {
  'Four Dots' => /\.\.\.\./,
  'Five Non-Alphanumerics' => /\W\W\W\W\W/,
  'Isolated Euro Sign' => /\S€\D/,
  'Double "Low-Nine" Quotes' => /„/,
  'Anomalous Pound Sign' => /£\D/,
  'Caret' => /\^/,
  'Guillemets' => /[«»]/,
  'Double Slashes and Pipes' => /(\\\/)|(\/\\)|([\/\\]\||\|[\/\\])/,
  'Bizarre Capitalization' => /([A-Z][A-Z][a-z][a-z])|([a-z][a-z][A-Z][A-Z])|([A-LN-Z][a-z][A-Z])/,
  'Mixed Alphanumerics' => /(\w[^\s\w\.\-]\w).*(\w[^\s\w]\w)/
}

WHITELIST_REGEXEN = {
  'Four Caps' => /[A-Z]{4,}/,
  'Date' => /Date/,
  'Likely year' => /1[98]\d\d|2[01]\d\d/,
  'N.S.F.' => /N\.S\.F\.|Fund/,
  'Lat Lon' => /Lat|Lon/,
  'Old style Coordinates' => /\d\d°\s?\d\d['’]\s?[NW]/,
  'Old style Minutes' => /\d\d['’]\s?[NW]/,
  'Decimal Coordinates' => /\d\d°\s?[NW]/,  
  'Distances' => /\d?\d(\.\d+)?\s?[mkf]/,  
  'Caret within heading' => /[NEWS]\^s/,
  'Likely Barcode' => /[l1\|]{5,}/,
  'Blank Line' => /^\s+$/,
  'Guillemets as bad E' => /d«t|pav«aont/  
}

module Header
  TERSE_HEADER="TERSE_FILE"
  NOISY_HEADER="NOISY_FILE"
end


def calculate_score(filename, negative=false)
  score = 0 
  non_blank_lines = 0
  total_lines = 0
  File.readlines(filename).each do |line|
    total_lines += 1
    non_blank_lines += 1 if /\S/ =~ line
    GARBAGE_REGEXEN.keys.each do |name|
      if GARBAGE_REGEXEN[name] =~ line
        unless WHITELIST_REGEXEN.values.inject(false) { |found,regex| found || regex =~ line} 
#          print "#{filename}: Found #{name} in #{line}!" if negative=='t'
          score += 1          
        end
      end
    end
  end
  [score, non_blank_lines,total_lines]
end


csv_file = ARGV[0]


 
line = 0
CSV.read(csv_file, :headers => true).each do |row|
  terse = calculate_score(row[Header::TERSE_HEADER])
  noisy = calculate_score(row[Header::NOISY_HEADER], row["VISUAL_CLASSIFICATION"])
#  print "#{File.basename(row[Header::TERSE_HEADER])}: terse=#{terse}, noisy=#{noisy}\n"

  # skip 0 line of gibberish in the terse output
  terse_b = terse[0]>0
  # skip less than 20% gibberish in the noisy output
  noisy_b = (noisy[0].to_f / noisy[1].to_f) > 0.2

  print "CLASSIFICATION,TERSE_SCORE,TERSE_NON_BLANK,TERSE_TOTAL_LINES,NOISY_SCORE,NOISY_NON_BLANK,NOISY_TOTAL_LINES,#{row.headers.join(',')}\n"   if line==0
  line +=1
  print "\"#{terse_b || noisy_b}\","
  print "#{terse.join(',')},#{noisy.join(',')},#{row.to_s}"
end


exit

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