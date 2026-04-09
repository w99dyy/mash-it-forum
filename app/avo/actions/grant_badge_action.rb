class Avo::Actions::GrantBadgeAction < Avo::BaseAction
  self.name = "Grant Badge"
  self.visible = -> { true }

  def fields
    field :badge_id, as: :select,
      label: "Badge",
      options: Merit::Badge.all.each_with_object({}) { |b, h| h[b.name] = b.id }
  end

  def handle(**args)
    query, fields = args.values_at(:query, :fields)

    query.each do |user|
      next if user.badges.select { |b| b.id.to_i > 0 }
                         .any? { |b| b.id == fields[:badge_id].to_i }

      user.add_badge(fields[:badge_id].to_i)
    end

    succeed "Badge granted successfully!"
  end
end
