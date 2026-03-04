require 'yaml'
require 'csv'

data_dir = '/usr/local/bin/users-data'
users_data = []

# Пробуем YAML сначала
yaml_file = File.join(data_dir, 'users.yaml')
if File.exist?(yaml_file)
  users_data = YAML.load_file(yaml_file)
  puts "Загружен YAML: #{users_data.size} пользователей"
elsif File.exist?(File.join(data_dir, 'users.csv'))
  csv_file = File.join(data_dir, 'users.csv')
  CSV.foreach(csv_file, headers: true) do |row|
    users_data << {
      username: row['username'],
      email: row['email'],
      name: row['name'],
      password: row['password']
    }
  end
  puts "Загружен CSV: #{users_data.size} пользователей"
else
  puts "Файлы users.yaml или users.csv не найдены в #{data_dir}"
  exit 1
end

users_data.each do |data|
  user = User.find_by(username: data[:username])
  unless user
    user = User.new(
      username: data[:username],
      email: data[:email],
      name: data[:name],
      password: data[:password],
      password_confirmation: data[:password]
    )
    user.skip_confirmation!
    if user.save!
      puts "Создан: #{data[:username]} (#{data[:email]})"
    else
      puts "Ошибка #{data[:username]}: #{user.errors.full_messages}"
    end
  else
    puts "Существует: #{data[:username]}"
  end
end

puts "Инициализация завершена"
