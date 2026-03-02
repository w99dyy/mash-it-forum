class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show, :edit, :update ]

  def show
    # @user is already set by set_user
  end

  def edit
    # Render edit form
  end

  def update
    if @user.update(profile_params)
      flash[:success] = "Profile updated successfully."
      redirect_to profile_path(@user)
    else
      flash[:error] = @user.errors.full_messages
      render :edit
    end
  end

  private

  def connect_wallet
    wallet_address = params[:wallet_address]

    if current_user.update(wallet_address: wallet_address)
      render json: { success: true, address: wallet_address }
    else
      render json: { error: "Failed to connect wallet" }, status: :unprocessable_entity
    end
  end

  def disconnect_wallet
    if current_user.update(wallet_address: nil, mashit_avatar_data: nil, mashit_avatar_url: nil)
      render json: { success: true }
    else
      render json: { error: "Failed to disconnect" }, status: :unprocessable_entity
    end
  end

  def update_avatar_from_wallet
    mashit_data = params[:mashit_data]
    wallet_address = params[:wallet_address]

    if current_user.update(
      mashit_avatar_data: mashit_data,
      mashit_avatar_url: mashit_data["image_url"],
      wallet_address: wallet_address
    )
      render json: { success: true, avatar_url: current_user.mashit_avatar_url }
    else
      render json: { error: "Failed to update avatar" }, status: :unprocessable_entity
    end
  end

  def set_user
    @user = User.find_by(username: params[:username]) || current_user
  end

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :phone, :description, :avatar)
  end
end
