class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def self.friendly_find_record(id, query = nil)
    model_class.find_by(username: id)
  end

  def actions
    action Avo::Actions::GrantBadgeAction
    action Avo::Actions::RevokeBadgeAction
  end

  def fields
    field :id, as: :id
    field :email, as: :text
    field :username, as: :text
    field :wallet_address, as: :text
    field :mashit_avatar_url, as: :code
    field :mashit_avatar_synced_at, as: :date_time
    field :admin, as: :boolean
    field :confirmation_token, as: :text
    field :confirmed_at, as: :date_time
    field :confirmation_sent_at, as: :date_time
    field :unconfirmed_email, as: :text
  #  field :level, as: :number
  #  field :avatar, as: :file
    field :topics, as: :has_many
    field :posts, as: :has_many
    field :comments, as: :has_many
  #  field :profile, as: :has_one
    field :badges, as: :text,
          name: "Badges",
          format_using: -> {
            record.badges
                  .select { |b| b.id.to_i > 0 }
                  .map(&:name)
                  .join(", ")
          }
  end
end
