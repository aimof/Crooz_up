class ShopController < ApplicationController

  def index
    @shop = Shop.all.order(rankin: :desc)
  end

  def update
    self.task_hour
  end

  def task_hour
    ranking = self.get_ranking_json
    shop_h = self.get_shop(ranking)
    shop_h.each do |key_s, value_h|
      self.get_shop_rankin(key_s)
      if Shop.where(shop_id: key_s).exists? then
        rankin_score_old_f = self.get_shop_rankin(key_s.to_i)
        rankin_score_new_f = value_h["rankin"].to_f + 9.0 * rankin_score_old_f / 10.0
        Shop.where(shop_id: key_s).update_all(rankin: rankin_score_new_f)
      else
        Shop.create(shop_id: key_s, shop_name: value_h["shop_name"], rankin: value_h["rankin"], popular_product: value_h["popular_product"], popular_product_url: value_h["popular_product_url"])
      end
    end
  end

  def get_ranking_json
    uri = URI.parse('http://api.biz.crooz.co.jp/v1/shoplist/item/ranking')
    params = Hash.new
    params.store("appid", "14")
    params.store("type", "sale")
    params.store("limit", "100")
    uri.query = URI.encode_www_form(params)
    req = Net::HTTP::Get.new uri
    req["x-app-secret-key"] = 'iuzt8ad5mkry8o2exgymeg6dxu3j5xv4ll8j5o60'
    res = Net::HTTP.start(uri.host, uri.port) {|http| http.request req }

    ranking = JSON.load(res.body)
    return ranking
  end

  def get_shop(data)
    data_array = data["ranking_data"]

    count = Hash.new

    data_array.each do |i|
      key = i["shop_id"]
      if count.has_key?(key.to_s) then
        add1 = count[key.to_s].to_i + 1
        count[key.to_s] = add1.to_s
      else
        count[key.to_s] = "1"
      end
    end

    shop_data = Hash.new { |h,k| h[k] = {} }
    count.each do |key, value|
      data_array.each do |i|
        if i["shop_id"] == key
          shop_data[key]["shop_name"] = i["shop_name"]
          shop_data[key]["rankin"] = count[key]
          shop_data[key]["popular_product"] = i["product_name"]
          shop_data[key]["popular_product_url"] = i["site_link_url"]
          break
        end
      end
    end
    return shop_data
  end

  def get_shop_rankin(id)
    @shop_row = Shop.where(shop_id: id)

    rank_in = String.new
    @shop_row.each do |shop_row|
      rank_in = shop_row.rankin
      break
    end
    return rank_in.to_f

  end

end
