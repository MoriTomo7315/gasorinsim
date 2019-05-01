class PagesController < ApplicationController

  @@params_temp_bike = {fuel_capa: 0, fuel_per1km: 0}
  @@params_temp_gasstand = {gas_cheap: 0, gas_littlecheap: 0, gas_normal: 0, gas_littleexpensive: 0, gas_expensive: 0}

  def index
    @bike = Bike.new
  end

  def set_gasstand
    @bike = Bike.new(fuel_capa: params[:bike][:fuel_capa], fuel_per1km: params[:bike][:fuel_per1km])
    @@params_temp_bike = {fuel_capa: params[:bike][:fuel_capa], fuel_per1km: params[:bike][:fuel_per1km]}
    @gasstand = Gasstand.new
  end

  def simulate
    @bike = Bike.new(fuel_capa: @@params_temp_bike[:fuel_capa], fuel_per1km: @@params_temp_bike[:fuel_per1km])
    @gasstand = Gasstand.new(gas_cheap: params[:gasstand][:gas_cheap], 
                            gas_littlecheap: params[:gasstand][:gas_littlecheap],
                            gas_normal: params[:gasstand][:gas_normal],
                            gas_littleexpensive: params[:gasstand][:gas_littleexpensive],
                            gas_expensive: params[:gasstand][:gas_expensive])
    @@params_temp_gasstand[:gas_cheap] = params[:gasstand][:gas_cheap]
    @@params_temp_gasstand[:gas_littlecheap] = params[:gasstand][:gas_littlecheap]
    @@params_temp_gasstand[:gas_normal] = params[:gasstand][:gas_normal]
    @@params_temp_gasstand[:gas_littleexpensive] = params[:gasstand][:gas_littleexpensive]                          
    @@params_temp_gasstand[:gas_expensive] = params[:gasstand][:gas_expensive]
  end

  def simulate_result
    simulate_time = (1..365).to_a
    normal_random = RandomBell.new
    distance_dist_Sat = RandomBell.new(mu: 10, sigma: 5)
    distance_dist_Sun = RandomBell.new(mu: 15, sigma: 5)
    fuel_tank     = 0
    fuel_capa     = @@params_temp_bike[:fuel_capa].to_f
    fuel_per1km   = @@params_temp_bike[:fuel_per1km].to_f
    fueling_litter = 0 # 給油量
    total_amountOfrefuel = 0 # 総給油量
    refueling_times = 0 # 給油回数
    running_distance = 0 # お出かけ距離
    total_running    = 0 # 総距離
    total_cost = 0 # 総コスト


    gas_price_array = [@@params_temp_gasstand[:gas_cheap].to_f, @@params_temp_gasstand[:gas_littlecheap].to_f,
                      @@params_temp_gasstand[:gas_normal].to_f, @@params_temp_gasstand[:gas_littleexpensive].to_f, 
                      @@params_temp_gasstand[:gas_expensive].to_f]

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

      # - - バイクのタンクチェック - - - -
      # 0.8L以下なら給油する
      if fuel_tank < 0.8
        fueling_litter = fuel_capa - fuel_tank
        total_amountOfrefuel += fueling_litter
        total_cost += gas_price * fueling_litter
        fuel_tank = fuel_capa
        refueling_times += 1
      end
      # - - - - - - - - - - - - - - - 
      
      # iが6ならば，土曜日であると仮定
      if i % 6 == 0
        # 0.15の確率でお出かけする．（土曜は少し疲れてるのであまり長距離ドライブはしたくない）
        if Random.rand(100)/100 < 0.15
          # お出かけの距離
          running_distance = distance_dist_Sat.rand
          # 距離が正になるよう調整
          while running_distance <= 0
              running_distance = distance_dist_Sat.rand
          end

        total_running += 2 * running_distance
        fuel_tank -= (1.0/fuel_per1km) * 2 * running_distance
        end
      elsif i % 7 == 0 #日曜
        # 0.2の確率でお出かけする．（日曜は元気だから長距離ドライブをしてもいいかな〜って気分）
        if Random.rand(100)/100 < 0.2
          running_distance = distance_dist_Sun.rand
          while running_distance <= 0
            running_distance = distance_dist_Sun.rand
          end
          total_running += 2 * running_distance
          fuel_tank -= (1.0/fuel_per1km) * 2 * running_distance
        end
      else # 平日
        # うちから大学まで7.6kmです．
        total_running += 2 * 7.6
        fuel_tank -= (1.0/fuel_per1km) * 2 * 7.6
      end
    end
    @totalCost = total_cost
    @totalRunning = total_running
    @refuelingTimes = refueling_times
    @totalAmountRefuel = total_amountOfrefuel
  end
end
