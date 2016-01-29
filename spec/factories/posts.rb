FactoryGirl.define do
  factory :post do
    subject {Faker::Hipster.sentence}
    body    {Faker::Hipster.paragraph(3)}
  end
end
