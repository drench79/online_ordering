class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  after_filter :store_location
  helper_method :platform_admin?, :current_order, :current_restaurant, :restaurant_admin?

  def store_location
    if (request.fullpath != "/users/sign_in" &&
        request.fullpath != "/users/sign_up" &&
        request.fullpath != "/users/password" &&
        request.fullpath != "/login" &&
        request.fullpath != "/logout" &&
        request.fullpath != "/restaurants/new" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def after_sign_out_path_for(resource)
    session[:previous_url] || root_path
  end

  def viewable_restaurants
    return Restaurant.all.order(:id) if platform_admin?
    Restaurant.where(display:true).order(:id)
  end

  def regions_with_restaurants
    Region.includes(:restaurants)
  end

  def platform_admin?
    current_user && current_user.platform_admin
  end

  def restaurant_admin?
    platform_admin? || current_restaurant.worker?(current_user)
  end

  def current_restaurant
    @current_restaurant ||= Restaurant.find_by(slug: request.original_fullpath.split("/")[1])
  end

  def current_order
    if session[:order_id]
      if current_restaurant.id == Order.find(session[:order_id]).restaurant.id
        Order.find(session[:order_id])
      else
        session[:order_id] = nil
      end
    else
      if Order.where(restaurant: current_restaurant).last && Order.where(restaurant: current_restaurant).last.incomplete?
        Order.where(restaurant: current_restaurant).last
      end
    end
  end

  def check_admin
    unless restaurant_admin?
      flash.alert = "Log in to see the admin page."
      redirect_to root_path
    end
  end
end
