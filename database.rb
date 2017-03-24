require 'csv'

class Person
  attr_reader "name", "phone", "address", "position", "salary", "slack", "github"

  def initialize(name, phone, address, position, salary, slack, github)
    @name = name
    @phone = phone
    @address = address
    @position = position
    @salary = salary
    @slack = slack
    @github = github
  end
end

class MyDatabase
  def initialize
    @people = []
    CSV.foreach("employees.csv", headers: true) do |row|
      name = row["name"]
      phone = row['phone']
      address = row["address"]
      position = row["position"]
      salary = row["salary"]
      slack = row["slack"]
      github = row["github"]

      person = Person.new(name, phone, address, position, salary, slack, github)

      @people << person
    end
  end

  def ask_question
    puts "What would you like to do?"
    puts "A to Add an Employee"
    puts "S to Search for an Employee"
    puts "D to Delete an Employee"
    puts "R to see a Report of all Employees"
    puts "Or just press enter to exit."
    choice = gets.chomp
    return choice.upcase
  end

  def add_person
    found_name = nil
    puts "What is the person's name?"
    name = gets.chomp
    found_name = @people.find { |person| person.name == name }
    if found_name
      puts "That Employee already exists.\n\n"
    elsif name.empty?
      puts "Name can not be blank"
    else
      puts "What is their phone number?"
      phone = gets.chomp

      puts "What is their address?"
      address = gets.chomp

      puts "What is their position?"
      position = gets.chomp

      puts "What is their salary?"
      salary = gets.chomp.to_i

      puts "What is their Slack account?"
      slack = gets.chomp

      puts "What is their GitHub account?"
      github = gets.chomp

      person = Person.new(name, phone, address, position, salary, slack, github)

      puts "You have added #{name}."
      puts "#{name}\'s phone number is #{phone}."
      puts "#{name} lives at #{address}."
      puts "Their position with the company is #{position} and they make $#{salary} a year."
      puts "Their Slack account is #{slack}."
      puts "Their GitHub account is #{github}.\n\n"

      @people << person

      save_database
    end
  end

  def search_for_person
    print "Please enter the person's name, Slack Account, or Github Account: "
    search_name = gets.chomp
    found_name = @people.find { |person| person.name == search_name || person.slack == search_name || person.github == search_name || person.name.include?(search_name) }
    if found_name
      puts "Search Results:\nName: #{found_name.name}\nPhone: #{found_name.phone}\nAddress: #{found_name.address}\nPosition: #{found_name.position}\nSalary: $#{found_name.salary}\nSlack: #{found_name.slack}\nGitHub: #{found_name.github}\n\n"
    else
      puts "That person does not exist.\n\n"
    end
  end

  def delete_person
    found_name = nil
    print "Please enter the name of the person you want to delete: "
    delete_name = gets.chomp
    found_name = @people.delete_if { |person| person.name == delete_name || person.slack == delete_name || person.github == delete_name }
    if found_name != nil
      puts "#{delete_name} has been deleted.\n\n"
    else
      puts "That person does not exist.\n\n"
    end
    save_database
  end

  def total_salary
    total_instructor_salary = 0
    total_campus_director_salary = 0
    total_instructors = @people.select { |person| person.position == "Instructor" }
    total_instructors.each do |person|
      total_instructor_salary += person.salary.to_i
    end
    total_director = @people.select { |person| person.position == "Campus Director" }
    total_director.each do |person|
      total_campus_director_salary += person.salary.to_i
    end
    printf("%-43s$%8d\n%-43s$%8d\n\n", "Total Salary of Instructors:", "#{total_instructor_salary}", "Total Salary of Campus Director:", "#{total_campus_director_salary}")
  end

  def total_by_position
    results = @people.group_by {|person| person.position}.map {|key,value| [key,value.count]}.to_h
    printf("%-30s\n", "Total Employees by Position:")
    results.each do |position,count|
      printf("%10s%18s%16d\n", " ", "#{position}:", "#{count}")
    end
  end

  def report_choice
    puts "How would you like your report?"
    puts "1. To view on your screen"
    puts "2. To print to an text file"
    puts "3. To print to an HTML file"
    puts "Or just press enter to exit."
    r_choice = gets.chomp
    return r_choice
  end

  def employee_report_console
    @people.each do |person|
      printf("%-10s%-30s%12s\n%10s%-33s$%8d\n%10s%-30s%12s\n\n", "#{person.name}", "#{person.address}", "#{person.phone}", " ", "#{person.position}", "#{person.salary}", " ", "#{person.slack}", "#{person.github}")
    end
    total_salary
    total_by_position
    puts "End of Report\n\n"
  end

  def employee_report_text_file
    File.open("employee-report.txt", "w") do |text|
      @people.each do |person|
        text.printf("%-10s%-30s%12s\n%10s%-33s$%8d\n%10s%-30s%12s\n\n", "#{person.name}", "#{person.address}", "#{person.phone}", " ", "#{person.position}", "#{person.salary}", " ", "#{person.slack}", "#{person.github}")
        total_salary
        total_by_position
      end
      text.puts "End of Report\n\n"
    end
    puts "Saving Text file...\n\n"
  end

  def employee_report_html
    File.open("employee-report.html", "w") do |html|
      html.write(<DOCTYPE!>\n)
      @people.each do |person|
        html.printf("%-10s%-30s%12s\n%10s%-33s$%8d\n%10s%-30s%12s\n\n", "#{person.name}", "#{person.address}", "#{person.phone}", " ", "#{person.position}", "#{person.salary}", " ", "#{person.slack}", "#{person.github}")
      end
      html.puts "End of Report\n\n"
    end
    puts "Saving HTML file..."
  end

  def employee_report
    r_choice = report_choice
    if r_choice == "1"
      employee_report_console
    elsif r_choice == "2"
      employee_report_text_file
    elsif r_choice == "3"
      employee_report_html
    else
      puts "That is not one of the choices.\n\n"
    end
  end

  def save_database
    CSV.open("employees.csv", "w") do |csv|
      csv << ["name", "phone", "address", "position", "salary", "slack", "github"]
      # csv = %w{name phone address position salary slack github}
      @people.each do |person|
        csv << [person.name, person.phone, person.address, person.position, person.salary, person.slack, person.github]
      end
    end
  end

  def start
    choice = ()
    while choice != ""
      choice = ask_question
      if choice == "A"
        add_person
      elsif choice == "S"
        search_for_person
      elsif choice == "D"
        delete_person
      elsif choice == "R"
        employee_report
      else
        puts "Saving and exiting...\n\n"
        save_database
      end
    end
  end
end

MyDatabase.new.start
