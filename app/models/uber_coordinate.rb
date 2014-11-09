class UberCoordinate < ActiveRecord::Base
	has_many :vehicles, :dependent => :destroy
	has_many :products, :dependent => :destroy
	validates_presence_of :location, :latitude, :longitude
	after_create :query_start

	geocoded_by :location
	before_validation :geocode, :unless => :longitude_changed?
	
	def query_start
		products = CLIENT.products.get(latitude: self.latitude, longitude: self.longitude)
		if products.size == 0
			return
		end
		products.each_index do |index|
			Product.create(uber_coordinate_id: self.id, product_id: products[index][:product_id], product_name: products[index][:display_name])
		end
		self.query
	end


	def query 
		price_estimates = CLIENT.price_estimates.get(start_latitude: self.latitude , start_longitude: self.longitude, end_latitude: self.latitude, end_longitude: self.longitude)
		if price_estimates.size == 0
			return
		end
		time_estimates = CLIENT.time_estimates.get(start_latitude: self.latitude, start_longitude: self.longitude)
			time_estimates.each_index do |index|
				vehicle = Vehicle.new(uber_coordinate_id: self.id, product: time_estimates[index][:product_id], eta: time_estimates[index][:estimate])
				#Ensure that time_estimates corresponds to price_estimates
				price_estimates.each_index do |i|
					if price_estimates[i][:product_id] == vehicle.product
						vehicle.surge = price_estimates[i][:surge_multiplier]
						vehicle.save
						break
					end
				end
			end
			#run every hour
		UberCoordinate.delay(run_at: 1.hour.from_now).repeat(self.id)
	end


	def self.repeat(id)
		last = UberCoordinate.find(id)
		last.query
	end

end

