class Flat < ApplicationRecord
  has_many :listings
  belongs_to :floorplan, optional: true
  validates :bed, :bath, :sqft, numericality: { only_integer: true }

  def name
    floor + stack
  end

  def price_score
    current_price = listings.last.price
    return normalize(current_price, 2800, 4700, true)
  end

  def window_score
    window_avg = 0
    unless floorplan.nil? || floorplan.window_array.blank?
      window_avg = floorplan.window_array.sum/floorplan.window_array.count
    end
    return normalize(window_avg, 1, 4, false)
  end

  def view_score
    view = 0
    unless city_view.nil?
      view = city_view_before_type_cast
    end
    return normalize(view, 0, 3, false)
  end

  def floor_score
    return normalize(floor.to_i, 3, 37, false)
  end

  def sqft_score
    return normalize(sqft, 463, 906, false)
  end

  def value_score
    return (price_score * 3.5) + window_score + (view_score/2) + (floor_score/2) + sqft_score
  end

  def layout_path
    if floorplan.hirise['jasper']
      unit = name
      if floor.length == 1
        unit = "0" + floor + stack
      end
      "https://www.rentjasper.com/wp-content/uploads/2015/05/Jasper_Web_#{unit}.svg"
    else
      floorplan.layout_path
    end
  end

  def all_listings
    listings_array = []
    listings.each do |l|
      listings_array.push({'price': l[:price], 'created-at': l[:created_at]})
    end
    return listings_array
  end

  enum city_view: {'Totally Obstructed': 0, 'Mostly Obstructed': 1, 'Partially Obstructed': 2, 'Unobstructed': 3}
end
