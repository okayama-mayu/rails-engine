require 'rails_helper'

describe 'Merchants API' do 
  it 'sends a list of Merchants' do 
    create_list(:merchant, 3)

    get '/api/v1/merchants' 

    expect(response).to be_successful 

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants).to be_a Hash
    expect(merchants[:data]).to be_an Array 

    expect(merchants[:data].count).to eq 3 

    merchants[:data].each do |merchant| 
      expect(merchant).to have_key(:id) 
      expect(merchant[:id]).to be_a String  

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a String 
    end
  end

  it 'can get one Merchant by its id' do 
    id = create(:merchant).id 

    get "/api/v1/merchants/#{id}"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful 

    merchant_data = merchant[:data]

    expect(merchant_data).to have_key(:id) 
    expect(merchant_data[:id]).to eq id.to_s
    expect(merchant_data[:id]).to be_a String 

    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant_data[:attributes][:name]).to be_a String 
  end

  it 'returns an error if item does not exist for show' do 
    create_list(:merchant, 5)
    id = Merchant.last.id + 1000

    get "/api/v1/merchants/#{id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(404)
  end

  it 'returns all Items for a given Merchant id' do 
    merchant = create(:merchant)
    item_1 = merchant.items.create!(name: Faker::Device.model_name, description: Faker::Lorem.sentence, unit_price: Faker::Commerce.price)
    item_2 = merchant.items.create!(name: Faker::Device.model_name, description: Faker::Lorem.sentence, unit_price: Faker::Commerce.price)
    item_3 = merchant.items.create!(name: Faker::Device.model_name, description: Faker::Lorem.sentence, unit_price: Faker::Commerce.price)

    merchant_2 = create(:merchant)
    item_4 = merchant_2.items.create!(name: Faker::Device.model_name, description: Faker::Lorem.sentence, unit_price: Faker::Commerce.price)

    get "/api/v1/merchants/#{merchant.id}/items"

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    items_data = items[:data]

    expect(items_data.count).to eq 3 
    
    items_data.each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_a String 

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a String 

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a String 

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a Float

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to eq merchant.id
    end 
  end 
  
  it 'returns a 404 if Merchant is not found' do 
    merchant = create(:merchant)
    item_1 = merchant.items.create!(name: Faker::Device.model_name, description: Faker::Lorem.sentence, unit_price: Faker::Commerce.price)
    item_2 = merchant.items.create!(name: Faker::Device.model_name, description: Faker::Lorem.sentence, unit_price: Faker::Commerce.price)
    item_3 = merchant.items.create!(name: Faker::Device.model_name, description: Faker::Lorem.sentence, unit_price: Faker::Commerce.price)

    merchant_2 = create(:merchant)
    item_4 = merchant_2.items.create!(name: Faker::Device.model_name, description: Faker::Lorem.sentence, unit_price: Faker::Commerce.price)

    get "/api/v1/merchants/#{merchant.id + 50}/items"

    expect(response).to have_http_status(404)
  end 

  it 'finds a single merchant which matches a search term' do 
    john = Merchant.create!(name: 'John Doe')
    joe = Merchant.create!(name: 'Joe Manchin')
    jolene = Merchant.create!(name: 'Jolene Smith')
    darrel = Merchant.create!(name: 'Darrel Jones')
    priyanka = Merchant.create!(name: 'Priyanka Chopra')

    get "/api/v1/merchants/find?name=jo"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful 

    merchant_data = merchant[:data]

    expect(merchant_data).to have_key(:id) 
    expect(merchant_data[:id]).to eq darrel.id.to_s

    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant_data[:attributes][:name]).to eq darrel.name 
  end

  it 'returns an empty hash if Merchant is not found' do 
    john = Merchant.create!(name: 'John Doe')
    joe = Merchant.create!(name: 'Joe Manchin')
    jolene = Merchant.create!(name: 'Jolene Smith')
    darrel = Merchant.create!(name: 'Darrel Jones')
    priyanka = Merchant.create!(name: 'Priyanka Chopra')

    get "/api/v1/merchants/find?name=cat"

    expect(response).to be_successful

    merchant = JSON.parse(response.body, symbolize_names: true)

    merchant_data = merchant[:data]

    expect(merchant_data).to eq({})
  end
end