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




		calculated_meal_type_by_time = case Time.now.hour
		when 0..6 then 'none'
		when 7..10 then 'breakfast'
		when 11..16 then 'lunch'
		when 16..23 then 'dinner'
		end


		parsed_meal_type = ['breakfast', 'lunch', 'dinner'].include?(meal_type) ? meal_type : calculated_meal_type_by_time

		formatted_response = "I didn't understand your query"


		if parsed_meal_type == 'none'
			formatted_response = "It's too late right now to find food."
		elsif location.blank?
			formatted_response = "Where are you looking for a #{parsed_meal_type}?"
			
		else

			my_coordinates = get_coordinates(location)
			airtable_result = parse_airtable(meal_type, my_coordinates).first

			location_name, location_address, location_distance, location_subway_line, location_subway_stop = [
				airtable_result['fields']['name'],
				airtable_result['fields']['address'],
				airtable_result['distance'].round(2),
				airtable_result['fields']['subway_lines'],
				airtable_result['fields']['subway_stop']
			]


			formatted_response = "It sounds like you are looking for #{parsed_meal_type} near #{location.titlecase.strip}. \n\n" \
			"The nearest place for #{parsed_meal_type} from there is #{location_name.titlecase.strip}, " \
			"at #{location_address.titlecase.strip}, about #{location_distance} miles from #{location.titlecase.strip}. \n\n" \
			"The closest subway station is the #{location_subway_stop.titlecase.strip} stop, on the #{location_subway_line.strip} train." 

			formatted_response
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


	def get_coordinates(location)
		location = location + ", new york city"
		puts "Trying to get coordinates for #{location}"
		coordinates = Geocoder.coordinates(location)
		puts "Coordinates for #{location} are #{coordinates.to_s}"
		return coordinates
	end






	def parse_airtable(meal_type, my_coordinates)


		
		distance_threshold = 1.00 # set this as the distance threshold miles, to include search results for. This can be tweaked as needed

		airtable_json = Kitchen.grab_airtable(meal_type)


		airtable_json['records'].each do |record|
			record['distance'] = Geocoder::Calculations.distance_between(my_coordinates, [record['fields']['lat'], record['fields']['lng']])
		end


		sorted_results = airtable_json['records'].select{|record| record['distance'].to_f < distance_threshold}.sort_by{|record| record['distance'].to_f}


		puts JSON.pretty_generate(sorted_results)

		return sorted_results



	end







	def destroy_session
		request.session_options[:skip] = true
	end


end
