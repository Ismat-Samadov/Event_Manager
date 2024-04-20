# Event Manager

Event Manager is a Ruby script designed to manage event attendees, send thank you letters, and analyze registration patterns. It utilizes CSV parsing, Google Civic Information API, and ERB templates to accomplish these tasks.

## Features

- **Attendee Management**: Parses a CSV file containing attendee data and processes each entry.
- **Thank You Letters**: Generates personalized thank you letters for each attendee and saves them as HTML files.
- **Legislator Information**: Utilizes the Google Civic Information API to retrieve information about legislators based on zip codes.
- **Data Analysis**: Analyzes registration patterns to determine the most active hour and day of the week.

## Prerequisites

Before running the script, ensure you have the following installed:

- Ruby (version 2.6 or higher)
- Bundler gem (for managing gem dependencies)

## Installation

1. Clone the repository:

```
git clone https://github.com/Ismat-Samadov/Event_Manager.git
```

2. Navigate to the project directory:

```
cd Event_Manager
```

3. Install dependencies:

```
bundle install
```

## Usage

1. Prepare a CSV file (`event_attendees.csv`) containing attendee data. The file should have columns for `id`, `first_name`, `zipcode`, `regdate`, and `homephone`.

2. Ensure you have a valid API key for the Google Civic Information API. Replace the placeholder API key in the script (`legislators_by_zipcode` method) with your own.

3. Run the script:

```
ruby event_manager.rb
```

4. The script will process the attendee data, generate thank you letters, and perform data analysis. Results will be printed to the console.

## Configuration

You can customize the thank you letter template by modifying the `form_letter.erb` file. Customize the HTML structure and use embedded Ruby (ERB) tags to insert dynamic data.

## Contributing

Contributions are welcome! If you have any suggestions, bug fixes, or improvements, feel free to submit a pull request.