FactoryGirl.define do
  factory :user, aliases: [:author] do
    login { Faker::Name.name }
    email { Faker::Internet.email }
    name { Faker::Name.name }
  end
end
