namespace :admin do
  desc "Create or update an owner account using ADMIN_EMAIL and ADMIN_PASSWORD"
  task create: :environment do
    email = ENV.fetch("ADMIN_EMAIL").strip.downcase
    password = ENV.fetch("ADMIN_PASSWORD")
    owner_role = Role.find_or_create_by!(name: "owner") do |role|
      role.description = "Full administrative access, including user management and publishing."
    end
    user = User.find_or_initialize_by(email: email)
    user.assign_attributes(role: owner_role, active: true, password: password, password_confirmation: password)
    user.save!

    puts "Owner account ready for #{user.email}"
  end
end
