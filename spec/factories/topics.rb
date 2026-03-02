FactoryBot.define do
  factory :topic do
    title { "MyString" }
    content { "MyText" }
    user { nil }
    views_count { 1 }
    pinned { false }
    locked { false }
  end
end
