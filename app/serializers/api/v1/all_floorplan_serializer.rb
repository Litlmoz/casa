module Api::V1
  class AllFloorplanSerializer < ActiveModel::Serializer
    attributes :layout, :version, :hirise, :windows, :flats

    def layout
      object.layout_id
    end

    def version
      object.layout_version
    end

    def hirise
      object.hirise_before_type_cast
    end

    def flats
      flats_array = []
      object.flats.each do |f|
        flats_array.push({'floor': f[:floor], 'stack': f[:stack], 'sqft': f[:sqft]})
      end
      return flats_array
    end

  end
end
