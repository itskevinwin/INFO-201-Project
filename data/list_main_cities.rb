# file list_main_cities.rb
# author: Zetian Chen

# This ruby script reads in the filename of a file containing city names
#   (one city each line) and returns a csv file of city names
File.open(ARGV.first) do |f1|
    File.open('./main_cities.csv', 'w') do |f2|
    f2.puts "main.cities"
    f1.each_line {
        |line|
        line.strip!
        line.gsub!(/\s+/, ' ')
        f2.puts '"' << line << '"'
    }
    end
end
