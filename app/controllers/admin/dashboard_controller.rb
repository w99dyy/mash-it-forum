class Admin::DashboardController < Admin::BaseController
  def index
    @total_users = User.count
    @total_posts = Post.count
    @total_topics = Topic.count
  end
end
