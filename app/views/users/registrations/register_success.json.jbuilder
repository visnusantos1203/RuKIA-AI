json.status do
  json.code 200
  json.message "Signed up successfully."
end

json.token token

json.user do
  json.id user.id
  json.email user.email
  json.created_at user.created_at
  # Add any other user fields you want to expose
end
