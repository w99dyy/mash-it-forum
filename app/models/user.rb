class User < ApplicationRecord
  include Merit
  has_merit
  after_save :grant_admin_badge, if: :saved_change_to_admin?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  validates :username, presence: true, uniqueness: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_many :topics, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one :profile
  has_one_attached :avatar

  extend FriendlyId
  friendly_id :username, use: :slugged

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

    def mashit_layers
      return [] unless mashit_avatar_url.present?
      mashit_avatar_url.is_a?(Array) ? mashit_avatar_url : JSON.parse(mashit_avatar_url)
      rescue JSON::ParserError
      []
    end

    private

    def grant_admin_badge
      if admin?
        add_badge(2)
      else
        rm_badge(2)
      end
  end
end
