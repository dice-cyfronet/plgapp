require 'rails_helper'

RSpec.describe Ability do
  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }

  it 'app member can manage app' do
    app = create(:app)
    app.app_members.create(user: user, role: :master)

    expect(ability.can?(:edit, app)).to be_truthy
    expect(ability.can?(:update, app)).to be_truthy
    expect(ability.can?(:destroy, app)).to be_truthy
    expect(ability.can?(:deploy, app)).to be_truthy
    expect(ability.can?(:push, app)).to be_truthy
  end

  it 'app developer cannot manage app' do
    app = create(:app)
    app.app_members.create(user: user, role: :developer)

    expect_cannot_manage_app(app)
    expect(ability.can?(:deploy, app)).to be_truthy
  end

  it 'app reviewer cannot manage app' do
    app = create(:app)
    app.app_members.create(user: user, role: :reporter)

    expect_cannot_manage_app(app)
    expect(ability.can?(:deploy, app)).to be_falsy
  end

  def expect_cannot_manage_app(app)
    expect(ability.can?(:edit, app)).to be_falsy
    expect(ability.can?(:update, app)).to be_falsy
    expect(ability.can?(:destroy, app)).to be_falsy
    expect(ability.can?(:push, app)).to be_falsy
  end
end
