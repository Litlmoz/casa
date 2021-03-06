def pull_db_seed(url)
  url = URI.parse(url)

  response = Net::HTTP.start(url.host, use_ssl: true) do |http|
    http.get url.request_uri, 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A'
  end

  case response
  when Net::HTTPRedirection
    print 'Failed to seed db because the remote server issued a redirect'
  when Net::HTTPSuccess
    data_json = JSON.parse response.body
    response_json = data_json['data']

    return response_json
  else # failed to receive response code 200
    print "#{response.error!}"
  end
end

def pull_pricing_history
  unless Flat.exists?
    puts "Pulling pricing history..."
    flats_listings_json = pull_db_seed(ENV['ALL_FLATS_LISTINGS'])
    flats_listings_json.each do |flat|
      json = flat['attributes']
      flat = Flat.create!(bed: json['bed'], bath: json['bath'], stack: json['stack'], floor: json['floor'], sqft: json['sqft'], city_view: json['city-view'], is_active: false)

      json['listings'].each do |listing|
        Listing.create!(flat: flat, price: listing['price'], created_at: listing['created-at'])
      end
    end
    puts "Pricing history pulled successfully."
  end
end

def pull_floorplans
  unless Floorplan.exists?
    puts "Pulling stored floorplans..."
    floorplans_json = pull_db_seed(ENV['ALL_FLOORPLANS'])

    floorplans_json.each do |floorplan|
      json = floorplan['attributes']
      floorplan = Floorplan.create!(layout_id: json['layout'], layout_version: json['version'], hirise: json['hirise'], windows: json['windows'])

      json['flats'].each do |flat|
        flat = Flat.find_by!(floor: flat['floor'], stack: flat['stack'], sqft: flat['sqft'])
        flat.update! floorplan: floorplan
      end
    end
    puts "Floorplans pulled successfully."
  end
end

pull_pricing_history
pull_floorplans
