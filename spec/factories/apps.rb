FactoryGirl.define do
  factory :app do
    name { Faker::Name.name }
    subdomain { Faker::Internet.domain_word }
  end
end