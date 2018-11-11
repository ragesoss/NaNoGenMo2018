require 'open-uri'

# https://github.com/fogleman/primitive
# Download and build the PrimitivePic go program
PRIMITIVE_PATH = '~/go/bin/primitive'

# make a primitivepic version of a photo from the web
class Primitive
  def initialize(photo_url, name)
    @name = name

    File.write 'input.png', open(photo_url).read
    `~/go/bin/primitive -i input.png -o #{location} -n 300`
  end

  def location
    "images/#{@name.tr(' ', '_')}.png"
  end
end
