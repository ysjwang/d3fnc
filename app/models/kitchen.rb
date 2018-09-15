class Kitchen < ActiveRecord::Base
  
	def self.grab_airtable(view)

		['breakfast', 'lunch', 'dinner', 'all', 'code_blue', 'clothing'].include? view ? view : 'all'

		base_url = "https://api.airtable.com/v0/appIqVKLeqfYsByq8/meal_locations?api_key=keyYg0ZFrEK52u9db&view=#{view}"
		airtable_json = JSON.parse(Net::HTTP.get(URI(base_url)))


		offset = airtable_json['offset']
		while offset
			new_url = base_url + "&offset=#{offset}"
			new_airtable_json = JSON.parse(Net::HTTP.get(URI(new_url)))
			airtable_json['records'] = airtable_json['records'] + new_airtable_json['records']

			offset = new_airtable_json['offset']
		end

		airtable_json

	end


	private

	def self.list_addresses
		all_kitchens = Kitchen.grab_airtable('all')


		puts "All kitchens has #{all_kitchens['records'].count}"
		all_kitchens['records'].each do |record|
			record['lat_lng'] = Geocoder.coordinates(record['fields']['address'].to_s + ", New York")
			# record['distance'] = Geocoder::Calculations.distance_between(my_coordinates, record_coordinates)
			# puts "#{record['fields']['name']} - (#{record['lat_lng']})"
		end


		# puts "All kitchens has #{all_kitchens['records'].count}"

		# all_kitchens['records'].map{|r| [r['fields']['name'], r['lat_lng']]}

	end

end
