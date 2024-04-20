# IMPORT THE DATE LIBRARY FOR DATE MANIPULATION
require 'date'
# IMPORT THE CSV LIBRARY FOR CSV FILE PARSING
require 'csv'
# IMPORT THE GOOGLE CIVIC INFORMATION API LIBRARY
require 'google/apis/civicinfo_v2'
# IMPORT THE ERB LIBRARY FOR EMBEDDED RUBY TEMPLATES
require 'erb'

# ENSURE ZIP CODE FORMAT IS CONSISTENT (5 DIGITS)
def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

# RETRIEVE LEGISLATORS INFORMATION BASED ON ZIP CODE
def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

# CREATE OUTPUT DIRECTORY IF NOT EXISTS
def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exist?("output")

  filename = "output/thanks_#{id}.html"

  # WRITE THANK YOU LETTER CONTENTS TO FILE
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

# REMOVE NON-DIGIT CHARACTERS FROM PHONE NUMBER
def clean_phone_number(phone_number)
  phone_number.gsub!(/[^\d]/,'')
  # TRIM LEADING "1" FROM 11-DIGIT NUMBERS
  phone_number = phone_number[1..10] if phone_number.length == 11 && phone_number[0] == "1"
  # ENSURE PHONE NUMBER LENGTH IS 10 DIGITS
  phone_number.length == 10 ? phone_number : "Wrong Number!!"
end

# FIND THE MOST FREQUENT ELEMENT IN AN ARRAY
def most_frequent_element(array)
  array.max_by {|a| array.count(a)}
end

# PRINT INITIALIZATION MESSAGE
puts "EventManager initialized."

# OPEN CSV FILE FOR READING
contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
# GET NUMBER OF ENTRIES IN CSV FILE
contents_size = CSV.read('event_attendees.csv').length - 1
# READ CONTENTS OF TEMPLATE LETTER FILE
template_letter = File.read("form_letter.erb")
# CREATE AN ERB TEMPLATE OBJECT
erb_template = ERB.new(template_letter)
# CREATE AN ARRAY TO STORE HOUR OF DAY DATA
hour_of_day = []
# CREATE AN ARRAY TO STORE DAY OF WEEK DATA
day_of_week = []
# ARRAY TO MAP DAY OF WEEK INDEX TO DAY NAME
cal = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

# ITERATE THROUGH EACH ROW IN THE CSV FILE
contents.each_with_index do |row, idx|
  id = row[0]
  name = row[:first_name]
  # CLEAN ZIP CODE FROM CURRENT ROW
  zipcode = clean_zipcode(row[:zipcode])
  # GET LEGISLATORS INFORMATION BASED ON ZIP CODE
  legislators = legislators_by_zipcode(zipcode)
  # PARSE REGISTRATION DATE FROM CURRENT ROW
  reg_date = DateTime.strptime(row[:regdate], "%m/%d/%y %H:%M")
  # CLEAN PHONE NUMBER FROM CURRENT ROW
  phone_number = clean_phone_number(row[:homephone])

  # PRINT PROGRESS PERCENTAGE
  puts "------------#{((idx + 1).to_f / contents_size * 100).round(2)}%-----------"

  # ADD HOUR OF DAY TO ARRAY
  hour_of_day << reg_date.hour
  # ADD DAY OF WEEK TO ARRAY
  day_of_week << reg_date.wday

  # RENDER THANK YOU LETTER TEMPLATE
  form_letter = erb_template.result(binding)
  # SAVE THANK YOU LETTER TO FILE
  save_thank_you_letter(id, form_letter)
end

# PRINT MOST ACTIVE HOUR
puts "Most Active Hour: #{most_frequent_element(hour_of_day)}"
# PRINT MOST ACTIVE DAY
puts "Most Active Day: #{cal[most_frequent_element(day_of_week)]}"
