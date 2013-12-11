class RestaurantsController < ApplicationController
  def index
    @restaurants = viewable_restaurants
  end

  def show
    @restaurant = Restaurant.find(params[:id])
  end

  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = Restaurant.create!(restaurant_params)
    render :restaurant_confirmation
  end

  def update
    @restaurant = Restaurant.find(params[:id])
    
    if params[:status]
      @restaurant.status = params[:status]
    elsif params[:display]
      @restaurant.display = params[:display]
    end

    @restaurant.save
    redirect_to root_path
  end

  private
    def restaurant_params
      params.require(:restaurant).permit(:name, :description, :status)
    end

end
