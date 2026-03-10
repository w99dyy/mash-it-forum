class Admin::UsersController < BaseController
  def index
    @users = User.order(created_at: :desc)
  end

  def promote
    @user = User.find(params[:id])
    @user.update(admin: true)
    redirect_to admin_user_path, notice: "#{user.username} is now an admin!"
  end

  def demote
    @user = User.find(params[:id])
    @user.update(admin: false)
    redirect_to admin_user_path, notice: "#{user.username} is no longer an admin." 
  end
end
