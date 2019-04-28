class PagesController < ApplicationController
  def index
    @bike = Bike.new
  end

  def set_gasstand
    @bike = Bike.new(fuel_capa: params[:bike][:fuel_capa], fuel_per1km: params[:bike][:fuel_per1km])
    @gasstand = Gasstand.new
  end
end
