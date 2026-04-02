namespace :user do
    desc "Give myself admin"
    task make_admin: :environment do
        user = User.find_by(email: "huzskywalker@tutamail.com")
        if user
            user.update(admin: true)
            puts "User #{user.email} is now admin!"
        else
            puts "#{user.email} not found!"
        end
    end
end
