class FlatSerializer < ActiveModel::Serializer
  attributes :bed, :bath, :stack, :floor, :sqft, :is_active, :windows, :latest_price, :price_updated_at, :layout_path

  def price_updated_at
    object.listings.last.created_at
  end

  def latest_price
    object.listings.last.price
  end

  def windows
    object.floorplan.studio_windows unless object.floorplan.nil?
  end

  def layout_path
    object.floorplan.layout_path unless object.floorplan.nil?
  end
end
