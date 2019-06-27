class KitchensController < ApplicationController
	# AIzaSyCvoGBFIcKXBYN5WxIz2yGUSnAWnaasztw


	protect_from_forgery with: :null_session

	skip_before_action :verify_authenticity_token

	before_action :destroy_session


	def d3fnc
		respond_to do |format|
			# format.html { redirect_to render_d3fnc_kitchens_url }
			# format.json { redirect_to render_d3fnc_kitchens_url }
			format.json do


				render_d3fnc
			end
		end

	end


	def render_d3fnc

		distance_threshold = 1.00 # set this as the distance threshold miles, to include search results for. This can be tweaked as needed

		# puts "Begin params"
		# puts JSON.pretty_generate(params[:result][:metadata])
		# puts "End params"

		intent_name = params[:result][:metadata][:intentName].to_s

		meal_type = params[:result][:parameters][:meal_type].to_s
		location = params[:result][:parameters][:location][:"business-name"].to_s

		puts "Intent was #{intent_name}"
		puts "Meal type was #{meal_type} - OR #{params[:result][:parameters]}"
		puts "Location was #{location} - OR #{params[:result][:parameters][:location]}"



		# Location was {"country"=>"", 
		# 	"city"=>"", "admin-area"=>"", 
		# 	"business-name"=>"times square", 
		# 	"street-address"=>"", 
		# 	"zip-code"=>"", 
		# 	"shortcut"=>"", 
		# 	"island"=>"", 
		# 	"subadmin-area"=>""}

		calculated_meal_type_by_time = case Time.now.hour
		when 0..6 then 'none'
		when 7..10 then 'breakfast'
		when 11..16 then 'lunch'
		when 16..23 then 'dinner'
		end


		parsed_meal_type = ['breakfast', 'lunch', 'dinner'].include?(meal_type) ? meal_type : calculated_meal_type_by_time

		formatted_response = "I didn't understand your query."


		my_coordinates = get_coordinates(location)



		if intent_name == 'code_blue'

			
			formatted_response = "I couldn't find a place with an open bed."
			airtable_results = parse_airtable('code_blue', my_coordinates, distance_threshold)
			primary_result = airtable_results.first

			location_name, location_address, location_distance, location_subway_line, location_subway_stop, code_blue_capacity = [
				primary_result['fields']['name'],
				primary_result['fields']['address'],
				primary_result['distance'].round(2),
				primary_result['fields']['subway_lines'],
				primary_result['fields']['subway_stop'],
				(primary_result['fields']['code_blue_capacity'].to_f * 100).round.to_i
			]


			formatted_response = "It sounds like you are looking for an open shelter near #{location.titlecase.strip}. \n\n" \
			"The nearest place with Code Blue support from there is #{location_name.titlecase.strip}, " \
			"at #{location_address.titlecase.strip}, about #{location_distance} miles from #{location.titlecase.strip}. \n\n" \
			"There are currently #{code_blue_capacity} beds open. \n\n" \
			"The closest subway station is the #{location_subway_stop.titlecase.strip} stop, on the #{location_subway_line.strip} train. \n\n" \
			"There are #{airtable_results.count - 1} other results within #{distance_threshold} miles of #{location.titlecase.strip}."



		else


			if parsed_meal_type == 'none'
				puts "meal type was none"
				formatted_response = "It's too late right now to find food."
			elsif location.blank?
				puts "location was blank"
				formatted_response = "Where are you looking for a #{parsed_meal_type}?"
				
			else

				
				airtable_results = parse_airtable(parsed_meal_type, my_coordinates, distance_threshold)
				primary_result = airtable_results.first

				location_name, location_address, location_distance, location_subway_line, location_subway_stop = [
					primary_result['fields']['name'],
					primary_result['fields']['address'],
					primary_result['distance'].round(2),
					primary_result['fields']['subway_lines'],
					primary_result['fields']['subway_stop']
				]


				formatted_response = "It sounds like you are looking for #{parsed_meal_type} today near #{location.titlecase.strip}. \n\n" \
				"The nearest place for #{parsed_meal_type} from there is #{location_name.titlecase.strip}, " \
				"at #{location_address.titlecase.strip}, about #{location_distance} miles from #{location.titlecase.strip}. \n\n" \
				"The closest subway station is the #{location_subway_stop.titlecase.strip} stop, on the #{location_subway_line.strip} train. \n\n" \
				"There are #{airtable_results.count - 1} other results within #{distance_threshold} miles of #{location.titlecase.strip}."


			end
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
		coordinates = Geocoder.coordinates(location)
		return coordinates
	end






	def parse_airtable(page_type, my_coordinates, distance_threshold=1)



		airtable_json = Kitchen.grab_airtable(page_type)


		airtable_json['records'].each do |record|
			record['distance'] = Geocoder::Calculations.distance_between(my_coordinates, [record['fields']['lat'], record['fields']['lng']])
		end


		sorted_results = airtable_json['records'].select{|record| record['distance'].to_f < distance_threshold}.sort_by{|record| record['distance'].to_f}



		return sorted_results



	end







	def destroy_session
		request.session_options[:skip] = true
	end


end
