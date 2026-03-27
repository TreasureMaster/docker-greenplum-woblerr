# create-root-pat.rb
# Создаёт (или пересоздаёт) PAT для root и пишет его в файл в общем томе.

token_name   = 'bootstrap-token'
token_scopes = ['api', 'write_repository']
expires_at   = 365.days.from_now
output_path  = '/shared/bootstrap/root_pat.txt'

user = User.find_by_username('root')
unless user
  STDERR.puts "User root not found"
  exit 1
end

# Удаляем старые токены с таким именем
user.personal_access_tokens.where(name: token_name).find_each(&:destroy!)

token = user.personal_access_tokens.create!(
  scopes: token_scopes,
  name:   token_name,
  expires_at: expires_at
)

# генерируем значение
token.set_token(SecureRandom.hex(32))
token.save!

File.open(output_path, 'w', 0600) do |f|
  f.write(token.token)
end

puts "PAT for root written to #{output_path}"
