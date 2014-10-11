class UberCoordinate < ActiveRecord::Base
	has_many :vehicles, :dependent => :destroy
	validates_presence_of :location, :latitude, :longitude
	after_create :query

	geocoded_by :location
	before_validation :geocode, :unless => :longitude_changed?
	
	def query 
		price_estimates = CLIENT.price_estimates.get(start_latitude: self.latitude , start_longitude: self.longitude, end_latitude: self.latitude, end_longitude: self.longitude)
		if price_estimates.size == 0
			return
		end
		time_estimates = CLIENT.time_estimates.get(start_latitude: self.latitude, start_longitude: self.longitude)
			time_estimates.each_index do |index|
				Vehicle.create(uber_coordinate_id: self.id, product: price_estimates[index][:product_id], surge: price_estimates[index][:surge_multiplier], eta: time_estimates[index][:estimate])
			end
		UberCoordinate.delay(run_at: 15.minutes.from_now).repeat(self.id)
	end


	def self.repeat(id)
		last = UberCoordinate.find(id)
		last.query
	end

end
