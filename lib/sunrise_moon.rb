
require 'csv'


module Sunrise
  module Moon

    ECLIPSES = {
      'T' => 'Total Solar Eclipse',
      'A' => 'Annular Solar Eclipse',
      'H' => 'Hybrid (Annular/Total) Solar Eclipse',
      'P' => 'Partial Solar Eclipse',
      't' => 'Total (Umbral) Lunar Eclipse',
      'p' => 'Partial (Umbral) Lunar Eclipse',
      'n' => 'Penumbral Lunar Eclipse' }

    class << self

      def times(from, to, lon)

        moon = CSV.read('var/moon.csv')

        delta = lon.to_f * 4 * 60

        fr1 = from - 31 * 24 * 3600
        to1 = to + 31 * 24 * 3600

        rows = []
          #
        moon.each_with_index do |row, i|
          next if i == 0 || row.first == nil
          next if Time.parse(row.first) < fr1
          break if Time.parse(row.last) > to1
          rows << row
        end

        rows
          .collect { |row|
            %i{ new_moon first_quarter full_moon last_quarter }
              .zip([
                [ row[0], ECLIPSES[row[1]] ],
                [ row[2], nil ],
                [ row[3], ECLIPSES[row[4]] ],
                [ row[5], nil ] ]) }
          .flatten(1)
          .collect(&:flatten)
          .collect { |m, t, e|
            td = Time.parse(t + ' UTC') + delta
            [ td.strftime('%F'), m, td, e ] }
          .inject({}) { |h, a|
            h[a.first] = a
            h }
      end
    end
  end
end

