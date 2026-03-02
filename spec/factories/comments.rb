FactoryBot.define do
  factory :comment do
    author_name { "MyString" }
    body { "MyText" }
    posts { nil }
  end
end
