class Floorplan < ApplicationRecord
  has_many :flats
  serialize :windows
  store_accessor :windows, :window1, :window2, :window3, :window4, :window5
  validates :layout_id, numericality: { only_integer: true }

  default_scope { order(layout_id: :asc) }

  # convert layout_ids to a name
  def alph(x)
    array = ("AA".."ZZ").to_a
    return array[x]
  end

  def name
    "#{alph(layout_id.modulo(26*26))}: #{layout_version}"
  end

  def window_array
    unless windows.blank?
      array = windows.values
      array.delete_if(&:blank?)
      return array unless array.empty?
    end
  end

  def layout_path
    if hirise['nema'] && layout_version.blank?
      "https://www.rentnema.com/img/floorplans/pdf/NEMA_Floorplans-CH_WEB_#{layout_id}.pdf"
    elsif hirise['nema']
      "#{ENV['S3_URL']}#{layout_id}-#{layout_version}.png"
    elsif hirise['jasper'] && layout_version.blank?
      if flats.count == 0
        "#{ENV['S3_URL']}#{layout_id}-#{layout_version}.png"
      else
        flats.first.layout_path
      end
    elsif hirise['jasper']
      "#{ENV['S3_URL']}#{layout_id}-#{layout_version}.png"
    end
  end

  enum hirise: [:nema, :jasper]
end
