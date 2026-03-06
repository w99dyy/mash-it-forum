class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  validates :username, presence: true, uniqueness: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :topics, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one :profile

    def wallet_connected?
      wallet_address.present?
    end

    def display_wallet_address
      return nil unless wallet_address.present?
      "#{wallet_address[0..5]}...#{wallet_address[-4..-1]}"
    end

    def display_name
      username.presence || email.split("@").first
      username
    end

    # If you're storing mashit traits
    def mashit_traits
      return [] unless mashit_avatar_data.present?
      mashit_avatar_data["traits"] || []
    end

    def mashit_layers
      return [] unless mashit_avatar_url.present?
      mashit_avatar_url.is_a?(Array) ? mashit_avatar_url : JSON.parse(mashit_avatar_url)
      rescue JSON::ParserError
      []
    end

end
