require 'rails_helper'

RSpec.describe "bulk discounts index page" do
  before(:all) do
    @merchant1 = create(:merchant, name: "Ye Olde Test Shoppe", status: "enabled")


  end

  describe "user story 1" do
    it 'displays all my bulk discounts including their % off and quantity thresholds' do
      visit merchant_bulk_discounts_path(@merchant1)


    end


  end

end