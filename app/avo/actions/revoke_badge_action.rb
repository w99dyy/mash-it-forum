class Avo::Actions::RevokeBadgeAction < Avo::BaseAction
  self.name = "Revoke Badge"
  self.visible = -> { true }

  def fields
    field :badge_id, as: :select,
      label: "Badge",
      options: Merit::Badge.all.each_with_object({}) { |b, h| h[b.name] = b.id }
  end

  def handle(**args)
    query, fields = args.values_at(:query, :fields)

    query.each do |user|
      user.rm_badge(fields[:badge_id].to_i)
    end

    succeed "Badge revoked successfully!"
  end
end
