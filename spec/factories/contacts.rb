# coding: utf-8
require 'faker'

FactoryGirl.define do
  factory :contact do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    email { Faker::Internet.email }
    # sequence(:email){ |n| "johndoe#{n}@example.com" }

    after(:build) do |contact|
      [:home_phone, :work_phone, :mobile_phone].each do |phone|
        contact.phones << FactoryGirl.build(:phone, phone_type: phone, contact: contact)
      end
    end
    # 子预购件会继承父预购件的全部属性
    factory :invalid_contact do
      firstname nil
    end
  end
end
