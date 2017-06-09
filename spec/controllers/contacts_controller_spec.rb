# coding: utf-8
require "rails_helper"

RSpec.describe ContactsController, :type => :controller do

  let(:admin){ build_stubbed(:admin) }
  let(:user){ build_stubbed(:user) }

  let(:contact) do
    create(:contact, firstname: 'Lala', lastname: 'Smith')
  end

  let(:phones) do
    [
      attributes_for(:phone, phone_type: 'home'),
      attributes_for(:phone, phone_type: 'office'),
      attributes_for(:phone, phone_type: 'mobile')
    ]
  end

  let(:valid_attributes){ attributes_for(:contact)}
  let(:invalid_attributes){ attributes_for(:invalid_contact)}

  let(:smith) do
    create(:contact, lastname: 'Smith')
  end

  let(:jones) do
    create(:contact, lastname: 'Jones')
  end
  
  shared_examples_for 'public access to contacts' do
    describe 'GET #index' do

      
      context 'with params[:letter]' do
        it "populates an array of contacts starting with the letter" do
          get :index, letter: 'S'
          expect(assigns(:contacts)).to match_array([smith])
        end
        it "renders the :index view" do
          get :index, letter: 'S'
          expect(response).to render_template(:index)
        end
      end
      
      context 'without params[:letter]' do
        it "populates an array of all contacts" do
          get :index
          expect(assigns(:contacts)).to match_array([smith, jones])
        end
        it "renders the :index view" do
          get :index
          expect(response).to render_template(:index)
        end
      end
    end

    describe 'GET #show' do
      # 惰性计算，使用FactoryGirl.build_stubbed()生成完整的假冒对象(stub驭件)
      let(:contact) { build_stubbed(:contact, firstname: 'Lala', lastname: 'Smith') }

      before :each do
        # 创建mock桩件
        # http://www.rubydoc.info/github/rspec/rspec-mocks/RSpec/Mocks/ExampleMethods#allow-instance_method
        # Used to wrap a class in preparation for stubbing a method on instances of it.
        allow_any_instance_of(Contact).to receive(:persisted?).and_return(true)
        # Used to wrap an object in preparation for stubbing a method on it.
        allow(Contact).to receive(:order).with('lastname, firstname').and_return([contact])
        allow(Contact).to receive(:find).with(contact.id.to_s).and_return(contact)
        allow_any_instance_of(Contact).to receive(:save).and_return(true)

        get :show, id: contact 
      end

      it "assigns the requested contact to @contact" do
      #  contact = create(:contact)
      #  get :show, id: contact
        expect(assigns(:contact)).to eq(contact)
      end
      it "renders the :show template" do
      #  contact = create(:contact)
      #  get :show, id: contact
        expect(response).to render_template(:show)
      end
    end
  end

  shared_examples_for 'full access to contacts' do
    describe 'GET #new' do
      it "assigns a new Contact to @contact" do
        get :new
        expect(assigns(:contact)).to be_a_new(Contact)
      end

      it "assigns a home, office, and mobile phone to the new contact" do
        get :new
        phones = assigns(:contact).phones.map do |p|
          p.phone_type
        end
        expect(phones).to match_array %w(home office mobile)
      end
      
      it "renders the :new template" do
        get :new
        expect(response).to render_template(:new)
      end
    end
    
    describe 'GET #edit' do
      it "assigns the requested contact to @contact" do
        contact = create(:contact)
        get :edit, id: contact
        expect(assigns(:contact)).to eq(contact)
      end
      
      it "renders the :edit template" do
        contact = create(:contact)
        get :edit, id: contact
        expect(response).to render_template(:edit)
      end
    end
    
    describe "POST #create" do
      before :each do
        @phones = [
          attributes_for(:phone),
          attributes_for(:phone),
          attributes_for(:phone)
        ]
      end
      context "with valid attributes" do
        it "saves the new contact in the database" do
          # let(:phones)
          expect{ post :create, contact: attributes_for(:contact, phones_attributes: phones) }.to change(Contact, :count).by(1)
        end
        
        it "redirects to contacts#show" do
          post :create, contact: attributes_for(:contact, phones_attributes: phones)
          expect(response).to redirect_to(contact_path(assigns[:contact]))
        end
      end
      
      context "with invalid attributes" do
        it "does not save the new contact in the database" do
          expect{ post :create, contact: attributes_for(:invalid_contact) }.not_to change(Contact, :count)
        end
        
        it "re-renders the :new template" do
          post :create, contact: attributes_for(:invalid_contact)
          expect(response).to render_template(:new)
        end
      end
    end
    
    describe 'PATCH #update' do
      before :each do
        @contact = create(:contact, firstname: 'Lala', lastname: 'Lili')
      end
      context "with valid attributes" do
        #it "updates the @contact in the database" do
        #  patch :update, id: @contact, contact: attributes_for(:contact, firstname: 'Lary', lastname: 'Smith')
        #  @contact.reload
        #  expect(@contact.firstname).to eq("Lary")
        #  expect(@contact.lastname).to eq("Smith")
        #end
        it "locates the requested @contact" do
          # let(:contact) = contact
          # let(:valid_attributes){ attributes_for(:contact)}
          # stringify_keys() Returns a new hash with all keys converted to strings.
          allow(contact).to receive(:update).with(valid_attributes.stringify_keys){ true }
          patch :update, id: @contact, contact: attributes_for(:contact)
          expect(assigns(:contact)).to eq @contact
        end

        it "changes the contact's attributes" do
          patch :update, id: @contact, contact: attributes_for(:contact, firstname: 'Lara', lastname: 'Smith')
          @contact.reload
          expect(@contact.firstname).to eq 'Lara'
          expect(@contact.lastname).to eq 'Smith'
        end
        
        it "redirects to the update contact" do
          patch :update, id: @contact, contact: attributes_for(:contact)
          expect(response).to redirect_to @contact
        end
      end
      
      context "invalid attributes" do
        before :each do
          allow(contact).to receive(:update).with(invalid_attributes.stringify_keys) { false }
          patch :update, id: contact, contact: invalid_attributes
        end

        it "located the requested @contact" do
          expect(assigns(:contact)).to eq(contact)
        end
        
        it "does not change the contact's attributes" do
#          expect(assigns(:contact).reload.firstname).to eq(contact.firstname)
#          expect(assigns(:contact).reload.created_at.to_s).to eq(contact.created_at.to_s)
          expect(assigns(:contact).reload.attributes.map(&:to_s)).to eq(contact.attributes.map(&:to_s))
        end
        it "re-renders the edit template" do
          expect(response).to render_template(:edit)
        end
      end
    end
    
    describe 'DELETE #destroy' do
      before :each do
        @contact = create(:contact)
      end
      
      it "deletes the contact" do
        contact
        expect{ delete :destroy, id: contact }.to change(Contact, :count).by(-1)
      end
      
      it "redirects to users#index" do
        delete :destroy, id: @contact
        expect(response).to redirect_to contacts_url
      end
    end
  end
  
  describe "admin access" do
    before :each do
      allow(controller).to receive(:current_user).and_return(admin)
      # set_user_session create(:admin)
    end
    
    it_behaves_like 'public access to contacts'
    it_behaves_like 'full access to contacts'
    
  end

  describe "user access" do
    before :each do
      # set_user_session create(:user)
      allow(controller).to receive(:current_user).and_return(user)
    end

    it_behaves_like 'public access to contacts'
    it_behaves_like 'full access to contacts'
    
  end


  describe 'guest access' do
    it_behaves_like 'public access to contacts'
    
    describe 'GET#new' do
      it 'request login' do
        get :new
        expect(response).to require_login
      end
    end

    describe 'GET#edit' do
      it 'requires login' do
        contact = create(:contact)
        get :edit, id: contact
        expect(response).to require_login
      end
    end

    describe 'POST#create' do
      it 'requires login' do
        post :create, id: create(:contact), contact: attributes_for(:contact)
        expect(response).to require_login
      end
    end

    describe 'PUT#update' do
      it 'requires login' do
        put :update, id: create(:contact), contact: attributes_for(:contact)
        expect(response).to require_login
      end
    end

    describe 'DELETE#destroy' do
      it 'requires login' do
        delete :destroy, id: create(:contact)
        expect(response).to require_login
      end
    end
  end
  
end
