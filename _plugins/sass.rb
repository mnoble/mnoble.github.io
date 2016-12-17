require "sass"

module Jekyll
  class SassConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /sass/i
    end

    def output_ext(ext)
      ".css"
    end

    def convert(content)
      Sass::Engine.new(content).render
    end
  end
end

