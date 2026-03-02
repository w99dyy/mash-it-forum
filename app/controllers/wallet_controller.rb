class WalletController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :check_availability, :connect, :disconnect ]
  before_action :authenticate_user!

  def check_availability
    wallet_address = params[:wallet_address].downcase

    existing_user = User.find_by(wallet_address: wallet_address)

    if existing_user
      if existing_user == current_user
        render json: { available: true, message: "Wallet belongs to you" }
      else
        render json: {
          available: false,
          message: "This wallet is already connected to another account"
        }, status: :unprocessable_entity
      end
    else
      render json: { available: true, message: "Wallet available" }
    end
  end

  def connect
    wallet_address = params[:wallet_address].downcase

    # Check if wallet exists for another user
    existing_user = User.find_by(wallet_address: wallet_address)

    if existing_user && existing_user != current_user
      render json: {
        error: "This wallet is already connected to another account"
      }, status: :unprocessable_entity
      return
    end

    # Update user's wallet address in database
    current_user.update!(wallet_address: wallet_address)

    render json: { success: true, address: wallet_address }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def disconnect
    # Remove wallet address from database
    current_user.update!(wallet_address: nil)

    render json: { success: true }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
