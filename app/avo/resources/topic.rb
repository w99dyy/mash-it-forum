class Avo::Resources::Topic < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :title, as: :text
    field :content, as: :textarea
    field :user_id, as: :number
    field :views_count, as: :number
    field :pinned, as: :boolean
    field :locked, as: :boolean
    field :posts_count, as: :number
    field :user, as: :belongs_to
    field :posts, as: :has_many
    field :tag_list, as: :tags
  end
end
