users_data = [
  {
    username: 'root',
    email: 'root@example.com',
    name: 'Root User',
    password: 'root123456'
  },
  {
    username: 'admin',
    email: 'admin@example.com',
    name: 'Admin User',
    password: 'adminpass123'
  },
  {
    username: 'developer',
    email: 'dev@example.com',
    name: 'Developer User',
    password: 'devpass123'
  },
  {
    username: 'tester',
    email: 'tester@example.com',
    name: 'Tester User',
    password: 'testerpass123'
  }
  # Добавьте здесь больше пользователей по аналогии
]

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
      puts "Создан пользователь: #{data[:username]} (#{data[:email]})"
    else
      puts "Ошибка создания #{data[:username]}: #{user.errors.full_messages}"
    end
  else
    puts "Пользователь #{data[:username]} уже существует"
  end
end

puts "Инициализация завершена"
