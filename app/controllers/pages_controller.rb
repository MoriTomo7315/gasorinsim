class PagesController < ApplicationController

  # タンク容量、給油するときのメータ位置、燃費
  @@params_temp_vehicle = {fuel_capa: 0, fuel_per1km: 0 ,fuel_threshold: 0}
  # 平日の走行距離、休日の走行距離
  @@params_temp_distance = {dist_univ: 0, dist_holiday: 0}
  # 休日にお出かけする確率（:probability属性に格納予定）
  @@params_temp_probability = 0

  def index
    @simsetting = Simsetting.new
  end

  def simulate

    case params[:simsetting][:fuel_threshold]
    when "半分以上" then
      @@params_temp_vehicle[:fuel_threshold] = 0.6
    when "半分切ったら" then
      @@params_temp_vehicle[:fuel_threshold] = 0.4
    when "少なくなったら" then
      @@params_temp_vehicle[:fuel_threshold] = 0.3
    else
      @@params_temp_vehicle[:fuel_threshold] = 0.1
    end

    case params[:simsetting][:probability]
    when "ほぼほぼ" then
      @@params_temp_probability = 0.8
    when "半々" then
      @@params_temp_probability = 0.5
    when "気が向いたら" then
      @@params_temp_probability = 0.3
    else
      @@params_temp_probability = 0.1
    end


    @@params_temp_vehicle = {fuel_capa: params[:simsetting][:fuel_capa], 
                            fuel_per1km: params[:simsetting][:fuel_per1km]}
    
    @@params_temp_distance = {dist_univ: params[:simsetting][:dist_univ],
                              dist_holiday: params[:simsetting][:dist_holiday]}

    @simsetting = Simsetting.new(fuel_capa: params[:simsetting][:fuel_capa], 
                                fuel_per1km: params[:simsetting][:fuel_per1km], 
                                fuel_threshold: params[:simsetting][:fuel_threshold],
                                dist_univ: params[:simsetting][:dist_univ],
                                dist_holiday: params[:simsetting][:dist_holiday],
                                probability: params[:simsetting][:probability]
                                )
  end

  def simulate_result
    simulate_time        = (1..365).to_a
    normal_random        = RandomBell.new
    distance_dist_normal = @@params_temp_distance[:dist_univ].to_f
    distance_dist_holi   = RandomBell.new(mu: @@params_temp_distance[:dist_holiday].to_f, sigma: (@@params_temp_distance[:dist_holiday].to_f)/2)
    fuel_tank            = 0
    fuel_capa            = @@params_temp_vehicle[:fuel_capa].to_f
    fuel_per1km          = @@params_temp_vehicle[:fuel_per1km].to_f
    fuel_threshold       = fuel_tank * @@params_temp_vehicle[:fuel_threshold].to_f
    fueling_litter       = 0 # 給油量
    total_amountOfrefuel = 0 # 総給油量
    refueling_times      = 0 # 給油回数
    running_distance     = 0 # お出かけ距離
    total_running        = 0 # 総距離
    total_cost           = 0 # 総コスト


    gas_price_array = [ 140.0, 142.0, 144.0, 146.0, 148.0 ]

    simulate_time.each do |i|

      # - - - - 値段設定 - - - - - - - 
      if i == 0
        gas_price = gas_price_array[Random.rand(5)]
      else
        if Random.rand(100)/100 < 0.2
          gas_price = gas_price_array[Random.rand(5)]
        end
      end

      gas_price += normal_random.rand
      # - - - - - - - -  - - - - - - -

      # - - 車両のメータチェック - - - -
      if fuel_tank < fuel_threshold
        fueling_litter = fuel_capa - fuel_tank
        total_amountOfrefuel += fueling_litter
        total_cost += gas_price * fueling_litter
        fuel_tank = fuel_capa
        refueling_times += 1
      end
      # - - - - - - - - - - - - - - - 
      
      # iが6,7ならば，土曜日, 日曜日であると仮定
      if  i % 6 == 0 || i % 7 == 0
        if Random.rand(100)/100 < @@params_temp_probability
          # お出かけの距離
          running_distance = distance_dist_holi.rand
          # 距離が正になるよう調整
          while running_distance <= 0
              running_distance = distance_dist_holi.rand
          end

        total_running += 2 * running_distance
        fuel_tank -= (1.0/fuel_per1km) * 2 * running_distance
        end
      else # 平日
        total_running += distance_dist_normal
        fuel_tank -= (1.0/fuel_per1km) * distance_dist_normal
      end
    end
    @totalCost = total_cost
    @totalRunning = total_running
    @refuelingTimes = refueling_times
    @totalAmountRefuel = total_amountOfrefuel
  end
end
