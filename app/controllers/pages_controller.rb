class PagesController < ApplicationController
  def about
     @community_stats = {
      members: User.count,
      topics: Topic.count,
      posts: Post.count,
      admins: User.where(admin: true).count
    }

    @team_members = [
      { name: "Weedyy", role: "Forum developer and maintainer", github: "https://github.com/w99dyy" },

      { name: "Serhii", role: "Android app and Discord bot developer" },

      { name: "Atorcran", role: "Mash-it project developer" },

      { name: "Ervindas", role: "Frontend developer" },

      { name: "TurnipDaHeat", role: "Admin" },

      { name: "Potstar1", role: "Admin" },

     # { name: "Rylar", role: "Admin" },

      { name: "Kappajoe", role: " Admin" }

    ]
  end
end
