require 'date' # IMPORT THE DATE LIBRARY FOR DATE MANIPULATION
require 'csv' # IMPORT THE CSV LIBRARY FOR CSV FILE PARSING
require 'google/apis/civicinfo_v2' # IMPORT THE GOOGLE CIVIC INFORMATION API LIBRARY
require 'erb' # IMPORT THE ERB LIBRARY FOR EMBEDDED RUBY TEMPLATES

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4] # ENSURE ZIP CODE FORMAT IS CONSISTENT (5 DIGITS)
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new # CREATE A NEW INSTANCE OF THE CIVIC INFO SERVICE
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw' # SET THE API KEY

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials # RETRIEVE LEGISLATORS INFORMATION BASED ON ZIP CODE
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials" # HANDLE EXCEPTION
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exist?("output") # CREATE OUTPUT DIRECTORY IF NOT EXISTS

  filename = "output/thanks_#{id}.html" # CREATE FILENAME FOR THANK YOU LETTER

  File.open(filename, 'w') do |file|
    file.puts form_letter # WRITE THANK YOU LETTER CONTENTS TO FILE
  end
end

def clean_phone_number(phone_number)
  phone_number.gsub!(/[^\d]/,'') # REMOVE NON-DIGIT CHARACTERS FROM PHONE NUMBER
  phone_number = phone_number[1..10] if phone_number.length == 11 && phone_number[0] == "1" # TRIM LEADING "1" FROM 11-DIGIT NUMBERS
  phone_number.length == 10 ? phone_number : "Wrong Number!!" # ENSURE PHONE NUMBER LENGTH IS 10 DIGITS
end

def most_frequent_element(array)
  array.max_by {|a| array.count(a)} # FIND THE MOST FREQUENT ELEMENT IN AN ARRAY
end

puts "EventManager initialized." # PRINT INITIALIZATION MESSAGE

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol) # OPEN CSV FILE FOR READING
contents_size = CSV.read('event_attendees.csv').length - 1 # GET NUMBER OF ENTRIES IN CSV FILE
template_letter = File.read("form_letter.erb") # READ CONTENTS OF TEMPLATE LETTER FILE
erb_template = ERB.new(template_letter) # CREATE AN ERB TEMPLATE OBJECT
hour_of_day = [] # CREATE AN ARRAY TO STORE HOUR OF DAY DATA
day_of_week = [] # CREATE AN ARRAY TO STORE DAY OF WEEK DATA
cal = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday) # ARRAY TO MAP DAY OF WEEK INDEX TO DAY NAME

contents.each_with_index do |row, idx| # ITERATE THROUGH EACH ROW IN THE CSV FILE
  id = row[0] # GET ID FROM CURRENT ROW
  name = row[:first_name] # GET FIRST NAME FROM CURRENT ROW
  zipcode = clean_zipcode(row[:zipcode]) # CLEAN ZIP CODE FROM CURRENT ROW
  legislators = legislators_by_zipcode(zipcode) # GET LEGISLATORS INFORMATION BASED ON ZIP CODE
  reg_date = DateTime.strptime(row[:regdate], "%m/%d/%y %H:%M") # PARSE REGISTRATION DATE FROM CURRENT ROW
  phone_number = clean_phone_number(row[:homephone]) # CLEAN PHONE NUMBER FROM CURRENT ROW

  puts "------------#{((idx + 1).to_f / contents_size * 100).round(2)}%-----------" # PRINT PROGRESS PERCENTAGE

  hour_of_day << reg_date.hour # ADD HOUR OF DAY TO ARRAY
  day_of_week << reg_date.wday # ADD DAY OF WEEK TO ARRAY

  form_letter = erb_template.result(binding) # RENDER THANK YOU LETTER TEMPLATE
  save_thank_you_letter(id, form_letter) # SAVE THANK YOU LETTER TO FILE
end

puts "Most Active Hour: #{most_frequent_element(hour_of_day)}" # PRINT MOST ACTIVE HOUR
puts "Most Active Day: #{cal[most_frequent_element(day_of_week)]}" # PRINT MOST ACTIVE DAY
