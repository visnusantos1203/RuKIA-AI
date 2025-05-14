json.status do
  json.code 200
  json.message "Logged in successfully."
end

json.token token

json.user do
  json.id user.id
  json.email user.email
  json.created_at user.created_at
end
