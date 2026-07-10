FactoryBot.define do
  factory :topic do
    title { "rspec title test2" }
    association :user
    views_count { 1 }
    pinned { false }
    locked { false }
    posts_count { 1 }
    tag_list { "test" }
  end
end
