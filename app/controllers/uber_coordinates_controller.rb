class UberCoordinatesController < ApplicationController
  def new
  	@UberCoordinate = UberCoordinate.new
    @list = UberCoordinate.paginate(page: params[:page] ,per_page: 4).order('created_at DESC')
  end

  def create
  	UberCoordinate.create(location: uber_coordinate_params[:location])
  	redirect_to root_path
  end

  private

  def uber_coordinate_params
		params.require(:uber_coordinate).permit(:location)
	end
end
