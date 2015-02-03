FactoryGirl.define do
  factory :app do
    name { Faker::Name.name }
    subdomain { Faker::Internet.domain_word }
    author
  end
end