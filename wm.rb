def date_valid?(date)
  y = date[0].to_i
  m = date[1].to_i
  d = date[2].to_i
  Date.valid_date?(y, m, d)
end

module YearlyReport
  def yearly_report
    Dir.glob("#{$path}/*#{$year}*.txt").each do |filename|
      File.foreach(filename).with_index do |line, line_no|
        @splitted_line = line.split(',')
        lhr_init if $path == 'Data/lahore_weather'
        if line_no == @start_line_no
          @id_temp_mean = @splitted_line.index('Mean TemperatureC')
          @id_date = @splitted_line.index('GST') || @splitted_line.index('PKST') || @splitted_line.index('PKT')
          @id_humidity_mean = @splitted_line.index(' Mean Humidity')

        elsif line_no > @start_line_no
          date_given = @splitted_line[@id_date].split('-')
          if date_valid?(date_given)
            @arr_date << @splitted_line[@id_date]
            @arr_mean_temp << @splitted_line[@id_temp_mean].to_i
            @arr_mean_humidity << @splitted_line[@id_humidity_mean].to_i
          end
        end
      end
    end
    min_temp = @arr_mean_temp.min { |a, b| a <=> b }
    min_temp_date = @arr_date[@arr_mean_temp.index(min_temp)]

    max_temp = @arr_mean_temp.max { |a, b| a <=> b }
    max_temp_date = @arr_date[@arr_mean_temp.index(max_temp)]

    # p arr_mean_humidity

    max_humidity = @arr_mean_humidity.max { |a, b| a <=> b }
    max_humidity_date = @arr_date[@arr_mean_humidity.index(max_humidity)]
    "Highest: #{max_temp}C on #{max_temp_date} \nLowest: #{min_temp}C on #{min_temp_date} \nHumid: #{max_humidity}% on #{max_humidity_date}"
  end
end

module MonthlyReport
  def monthly_report
    Dir.glob("#{$path}/*#{$year}_#{$month}.txt").each do |filename|
      File.foreach(filename).with_index do |line, line_no|
        @splitted_line = line.split(',')
        if $path == 'Data/lahore_weather'
          @start_line_no = 1
          @lahore = true
        end
        if line_no == @start_line_no
          @id_temp_high = @splitted_line.index('Max TemperatureC')
          @id_temp_low = @splitted_line.index('Min TemperatureC')
          @id_humidity_mean = @splitted_line.index(' Mean Humidity')
        elsif line_no > @start_line_no
          @arr_max_temp << @splitted_line[@id_temp_high].to_i
          @arr_min_temp << @splitted_line[@id_temp_low].to_i
          @arr_mean_humidity << @splitted_line[@id_humidity_mean].to_i
        end
      end
    end
    if @lahore
      @arr_min_temp.pop
      @arr_max_temp.pop
      @arr_mean_humidity.pop
    end
  end

  def monthly_report_avg
    monthly_report
    avg_temp_high = @arr_max_temp.sum(0.0) / @arr_max_temp.size
    avg_temp_low = @arr_min_temp.sum(0.0) / @arr_min_temp.size
    avg_mean_himidity = @arr_mean_humidity.sum(0.0) / @arr_mean_humidity.size

    "Highest Average: #{avg_temp_high.round(2)}C \nLowest Average: #{avg_temp_low.round(2)}C \nAverage Humidity: #{avg_mean_himidity.round(2)}%"
  end

  def monthly_report_chart
    monthly_report
    puts "#{$month} #{$year}"
    date = 0
    len = @arr_min_temp.size
    len.times do
      print "\n#{date.next}  "
      max_line_len = @arr_max_temp[date]
      min_line_len = @arr_min_temp[date]
      min_line_len.times do
        print '+'.blue
      end
      max_line_len.times do
        print '+'.red
      end
      date = date.next
      print "  #{min_line_len}-#{max_line_len}\n"
    end
  end
end

class Reports
  def initialize
    @splitted_line = []
    @start_line_no = 0
    @id_date = 0
    @id_temp_mean = 0
    @id_humidity_mean = 0
    @id_temp_high = 0
    @id_temp_low = 0
    @lahore = false
    @arr_date = []
    @arr_mean_humidity = []
    @arr_max_temp = []
    @arr_min_temp = []
    @arr_mean_temp = []
  end

  def lhr_init
    @start_line_no = 1
    @lahore = true
  end

  include YearlyReport
  include MonthlyReport
end

require 'date'
require 'colorize'
mode = ARGV[0]
$time = ARGV[1]
$path = ARGV[2]

time = $time.split('/')
$year = time[0]
month_no = time[1].to_i

$month = Date::ABBR_MONTHNAMES[month_no]

if mode == '-e'
  puts Reports.new.yearly_report
elsif mode == '-a'
  puts Reports.new.monthly_report_avg
elsif mode == '-c'
  Reports.new.monthly_report_chart
else
  print "\nINVALID MODE\n\n"
end
