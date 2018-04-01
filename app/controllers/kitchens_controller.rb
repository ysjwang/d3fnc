class KitchensController < ApplicationController
	# AIzaSyCvoGBFIcKXBYN5WxIz2yGUSnAWnaasztw


	protect_from_forgery with: :null_session

	skip_before_action :verify_authenticity_token

	before_action :destroy_session

	def d3fnc
		@kitchens = ['one', 'two', 'three']
		# json_response(@kitchens)
		# render json: @kitchens, status: :ok
		json_response(@kitchens)
	end

	def test_d3fnc
		respond_to do |format|
			# format.html { redirect_to render_d3fnc_kitchens_url }
			# format.json { redirect_to render_d3fnc_kitchens_url }
			format.json do


				render_d3fnc
			end
		end

	end


	def render_d3fnc

		meal_type = params[:result][:parameters][:meal_type].to_s
		location = params[:result][:parameters][:location].values.first.to_s

		calculated_meal_type_by_time = 


		calculated_meal_type_by_time = case Time.now.hour
		when 0..6 then 'none'
		when 7..10 then 'breakfast'
		when 11..16 then 'lunch'
		when 16..23 then 'dinner'
		end


		parsed_meal_type = ['breakfast', 'lunch', 'dinner'].include?(meal_type) ? meal_type : calculated_meal_type_by_time

		formatted_response = "I didn't understand your query"


		if parsed_meal_type == 'none'
			formatted_response = "It's too late right now to find food. #{meal_type} and #{parsed_meal_type}"
		elsif location.blank?
			formatted_response = "Where are you looking for a #{parsed_meal_type}?"
			
		else

			airtable_result = parse_airtable(meal_type, location)

			location_name, location_address, location_distance = [
				airtable_result['fields']['name'],
				airtable_result['fields']['address'],
				airtable_result['distance'].round(2)
			]

			formatted_response = "It sounds like you are looking for #{parsed_meal_type} near #{location}. The nearest place for #{parsed_meal_type} to #{location} is #{location_name}, at #{location_address}, about #{location_distance} miles away"
		end

		@response = {
			speech: formatted_response,
			displayText: formatted_response
		}

		json_response(@response)
	end

	def json_response(object, status = :ok)
		response.headers['Content-Type'] = 'application/json'
		render json: object, status: status
	end






	def parse_airtable(meal_type, my_location)


	
		# my_coordinates = Geocoder.coordinates(my_location)
		# url = "https://api.airtable.com/v0/appIqVKLeqfYsByq8/meal_locations?api_key=keyYg0ZFrEK52u9db&view=#{meal_type}"
		json_response = Kitchen.grab_airtable(meal_type)


		json_response['records'].each do |record|
			# record_coordinates = Geocoder.coordinates(record['fields']['address'] + ", New York")
			record['distance'] = Geocoder::Calculations.distance_between(my_coordinates, [record['fields']['lat'], record['fields']['lng']])
		end

		sorted = json_response['records'].sort_by{|record| record['distance'].to_f}


		sorted.first



	end







	def destroy_session
		request.session_options[:skip] = true
	end


end
