class Api::V1::Merchants::SearchController < ApplicationController
  def show 
    merchant = Merchant.find_merchant(params[:name])
    merchant_json_response(merchant)
  end
end