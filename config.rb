# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

require "mini_magick"

activate :directory_indexes

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# activate :livereload

activate :external_pipeline,
  name: :webpack,
  command: build? ? 'yarn run build' : 'yarn run start',
  source: '.tmp/dist',
  latency: 1

# Layouts
# https://middlemanapp.com/basics/layouts/

page '/'
page '/films'
page '/cameras'

Analog::Config.load
Analog::Roll.each do |roll|
  roll.files.each do |file|
    path = File.join(roll.dir, file)
    relative_path = path.sub(Analog::Config.path, "")

    thumb_path = File.join("./source/images", relative_path)
    FileUtils.mkdir_p(File.dirname(thumb_path))
    unless File.exists?(thumb_path)
      image = MiniMagick::Image.open(path)
      image.resize "300x"
      image.write(thumb_path)
    end
  end
  proxy "/#{roll.roll_number}", "/roll.html", :locals => roll.to_h, layout: "layout"
end



helpers do
  def thumb_path(path)
    path.sub(Analog::Config.path + "/" , "")
  end
end

