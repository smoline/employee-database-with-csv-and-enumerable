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
    return choice
  end

  def add_person
    found_name = nil
    puts "What is the person's name?"
    name = gets.chomp
    found_name = @people.find { |person| person.name == name }
    if found_name != nil
      puts "That Employee already exists."
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
    found_name = @people.find { |person| person.name == search_name || person.slack == search_name || person.github == search_name }
    if found_name != nil
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

  def employee_report
    # @people.foreach 
    puts "Report\n\n"
  end

  def save_database
    CSV.open("employees.csv", "w") do |csv|
      csv << ["name", "phone", "address", "position", "salary", "slack", "github"]
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
