require 'yaml'
require 'csv'

# data_dir = '/usr/local/bin/users-data'
data_dir = '/usr/local/bin/gitlab-rails-init'
users_data = []
error_happened = false

yaml_file = File.join(data_dir, 'users.yaml')
csv_file  = File.join(data_dir, 'users.csv')

if File.exist?(yaml_file)
  users_data = YAML.load_file(yaml_file)
  puts "Загружен YAML: #{users_data.size} пользователей"
elsif File.exist?(csv_file)
  CSV.foreach(csv_file, headers: true) do |row|
    users_data << {
      'username' => row['username'],
      'email'    => row['email'],
      'name'     => row['name'],
      'password' => row['password']
    }
  end
  puts "Загружен CSV: #{users_data.size} пользователей"
else
  puts "Файлы users.yaml или users.csv не найдены в #{data_dir}"
  exit 1
end

# Зарезервированные имена (минимальный список, можно расширить)
RESERVED_USERNAMES = %w[
  admin root support help dashboard profile login signup users projects
].freeze

users_data.each do |raw|
  username = raw['username'] || raw[:username]
  email    = raw['email']    || raw[:email]
  name     = raw['name']     || raw[:name]
  password = raw['password'] || raw[:password]

  if username.nil? || email.nil? || name.nil? || password.nil?
    puts "Пропуск: неполные данные (#{username.inspect}, #{email.inspect})"
    next
  end

  if RESERVED_USERNAMES.include?(username.downcase)
    # new_username = "#{username}_user"
    puts "[ERROR]: Имя #{username} зарезервировано"
    error_happened = true
    break
    # username = new_username
  end

  # Делаем пароль чуть сложнее, если очень простой
  if password.length < 8
    # password = "#{password}_A1x!"  # минимальный «усилитель»
    puts "[ERROR]: Пароль #{username} содержит менее 8 символов"
    error_happened = true
    break
  end

  user = User.find_by(username: username)
  if user
    puts "Пользователь #{username} уже существует, пропуск"
    next
  end

  begin
    user = User.new(
      username: username,
      email:    email,
      name:     name,
      password: password,
      password_confirmation: password
    )

    # Назначаем personal namespace (важно, иначе ошибка Namespace can't be blank)
    if user.respond_to?(:assign_personal_namespace)
      user.assign_personal_namespace(Organizations::Organization.default_organization)
    else
      # старые/другие версии GitLab – на всякий случай
      user.ensure_personal_namespace!
    end

    user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
    user.save!

    puts "Создан пользователь: #{username} (#{email})"
  rescue => e
    puts "Ошибка создания #{username}: #{e.class}: #{e.message}"
    # raise
    error_happened = true
    break
  end
end

if error_happened
#   STDERR.puts "Инициализация пользователей прервана из-за ошибки"
  puts "Инициализация пользователей прервана из-за ошибки"
  exit 1
else
  puts "Инициализация пользователей завершена"
end
