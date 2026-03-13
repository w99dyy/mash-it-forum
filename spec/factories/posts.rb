FactoryBot.define do
    factory :post do
        title { "rspec post" }
        body { "test" }
        association :topic
        association :user
    end
end
