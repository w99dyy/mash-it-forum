module ApplicationHelper
    def user_has_badges?(user, badge_name)
        return false unless user && user.badges.present?

        user.badges.any? { |badge| badge.name == badge_name }
    end

    def badge_color(badge)
        colors = {
            "Developer" => "text-[#f7d969]",
            "Admin" => "text-[#de7220]"
        }
        colors[badge.name] || "text-white"
    end

end
