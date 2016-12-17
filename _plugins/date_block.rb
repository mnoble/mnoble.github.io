module Jekyll
  module DateBlock
    def to_date_block(date)
      date
      # date = Date.parse(date)
      # date.to_s
    end
  end
end

Liquid::Template.register_filter(Jekyll::DateBlock)
