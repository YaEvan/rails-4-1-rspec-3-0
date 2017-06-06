require "rails_helper"

RSpec.describe Phone, :type => :model do
  context "test rspec phone" do
    it "does not allow duplicate phone numbers per contact" do
      contact = create(:contact)
      home_phone = create(:home_phone,
                          contact: contact,
                          phone: "110-110-1111")
      
      mobile_phone = build(:mobile_phone,
                          contact: contact,
                          phone: "110-110-1111")
      #contact = create(:contact)
      #create(:home_phone,
      #       contact: contact,
      #       phone: '785-555-1234')
      #mobile_phone = build(:mobile_phone,
      #                     contact: contact,
      #                     phone: '785-555-1234')
      mobile_phone.valid?
      expect(mobile_phone.errors[:phone].size).to eq(1)
      #expect(mobile_phone.errors[:phone]).to include('has already been taken')
    end

    it "allows two contacts to share a phone number" do
      #contact = Contact.create(firstname: 'Mike',
      #                         lastname: 'Tester',
      #                         email: 'tester@example.com')
      #contact.phones.create(phone_type: 'home',
      #                      phone: '110-110-1111')
      #other_contact = Contact.new
      #other_phone = other_contact.phones.build(phone_type: 'home',
      #                                         phone: '110-110-1111')
      create(:home_phone, phone: '110-110-1111')
      other_phone = build(:home_phone, phone: '110-110-1111')
      other_phone.valid?
      expect(other_phone).to be_valid
    end
  end
end
