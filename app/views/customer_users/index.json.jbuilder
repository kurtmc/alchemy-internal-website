json.array!(@customer_users) do |customer_user|
  json.extract! customer_user, :id, :email, :password
  json.url customer_user_url(customer_user, format: :json)
end
