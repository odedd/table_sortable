FactoryGirl.define do
  factory :user do |f|
    f.first_name  'John'
    f.last_name   'Doe'
    f.email       'johndoe@gmail.com'
  end
end