# create-users.rb
users = [
  { username: 'ci-runner', email: 'ci-runner@local', name: 'CI Runner', password: 'SecurePass123!' },
  { username: 'testuser', email: 'testuser@local', name: 'Test User', password: 'SecurePass123!' },
  { username: 'deploy-bot', email: 'deploy@local', name: 'Deploy Bot', password: 'SecurePass123!' }
]

users.each do |attrs|
  user = User.find_by_username(attrs[:username])
  unless user
    user = User.new(
      username: attrs[:username],
      email: attrs[:email],
      name: attrs[:name],
      password: attrs[:password],
      password_confirmation: attrs[:password],
      confirmed_at: Time.now
    )
    if user.save
      puts "[INFO]: Пользователь #{attrs[:username]} создан"
    else
      puts "[ERROR]: Ошибка создания #{attrs[:username]}: #{user.errors.full_messages}"
    end
  else
    puts "[WARNING]: Пользователь #{attrs[:username]} уже существует"
  end
end
