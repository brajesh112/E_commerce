# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
		 u = User.new(name: "Brajesh", email: "sahubrajesh112@gmail.com", phone_number: "7869309851", password: "brajesh112", password_confirmation: "brajesh112", role: "admin" )
		 u.avatar.attach(io: File.open("#{Rails.root}/app/assets/images/profile.png"), filename: 'profile.png', content_type: 'image/png')
		 obj = StripePayment.create_customer(u)
		 u.stripe_id = obj.id
		 u.save!
# #   Character.create(name: "Luke", movie: movies.first)
# 	AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', role: 99) if Rails.env.development?