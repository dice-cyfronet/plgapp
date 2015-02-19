require 'rails_helper'

RSpec.describe HelpController do
  let(:user) { create(:user) }
  before { sign_in(user) }


  it 'chooses help for selected locale' do
    get :show

    expect(assigns(:doc_file).to_s).to end_with('README.en.md')
  end
end
