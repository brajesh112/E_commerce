# Seed the database with default data. Run with `bin/rails db:seed`.
# Everything here is idempotent (find_or_create_by), so it is safe to re-run.

# Admin user. find_or_initialize so re-seeding doesn't duplicate or re-charge
# Stripe for an existing account.
admin = User.find_or_initialize_by(email: "sahubrajesh112@gmail.com")
if admin.new_record?
  admin.assign_attributes(
    name: "Brajesh",
    phone_number: "7869309851",
    password: "brajesh112",
    password_confirmation: "brajesh112",
    role: "admin"
  )
  admin.avatar.attach(
    io: File.open(Rails.root.join("app/assets/images/profile.png")),
    filename: "profile.png",
    content_type: "image/png"
  )
  admin.stripe_id = StripePayment.create_customer(admin).id
  admin.save!
  puts "Created admin user #{admin.email}."
else
  puts "Admin user #{admin.email} already exists, skipping."
end

# Categories and sub-categories.
load Rails.root.join("db/seeds/categories.rb")
