class Kitchen < ActiveRecord::Base
  
	def self.grab_airtable(view)

		['breakfast', 'lunch', 'dinner', 'all'].include? view ? view : 'all'

		url = "https://api.airtable.com/v0/appIqVKLeqfYsByq8/meal_locations?api_key=keyYg0ZFrEK52u9db&view=#{view}"
		json_response = JSON.parse(Net::HTTP.get(URI(url)))

		json_response

	end


	private

	def self.list_addresses
		all_kitchens = Kitchen.grab_airtable('all')

		all_kitchens['records'].each do |record|
			record['lat_lng'] = Geocoder.coordinates(record['fields']['address'].to_s + ", New York")
			# record['distance'] = Geocoder::Calculations.distance_between(my_coordinates, record_coordinates)
		end

		all_kitchens['records'].map{|r| [r['fields']['name'], r['lat_lng']]}

	end

end
