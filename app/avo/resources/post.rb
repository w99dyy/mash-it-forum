class Avo::Resources::Post < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :title, as: :text
    field :body, as: :trix
    field :user_id, as: :number
    field :topic_id, as: :number
    field :comments_count, as: :number
    field :pinned, as: :boolean
    field :locked, as: :boolean
  #  field :images, as: :files
  #  field :avatar, as: :file
  #  field :cover_image, as: :file
    field :topic, as: :belongs_to
    field :user, as: :belongs_to
    field :comments, as: :has_many
  #  field :subjects, as: :tags
    field :tag_list, as: :tags
  end
end
