# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

require "mini_magick"

configure :development do
  activate :livereload
end

ignore ".git"

activate :directory_indexes

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end


activate :external_pipeline,
  name: :webpack,
  command: build? ? 'yarn run build' : 'yarn run start',
  source: '.tmp/dist',
  latency: 1

# Layouts
# https://middlemanapp.com/basics/layouts/

Analog::Config.load
@all_rolls ||= Analog::Roll.all
@all_films ||= Analog::Film.all
@all_cameras ||= Analog::Camera.all
page '/', :locals => { rolls: @all_rolls }
page '/films', :locals => { all_films: @all_films }
page '/cameras', :locals => { all_cameras: @all_cameras }

@all_rolls.each do |roll|
  proxy "/#{roll.roll_number}", "/roll.html", :locals => roll.to_h, layout: "layout"
end

unless File.exist?("source/.generated")
  @all_rolls.each do |roll|
    CLI::UI::StdoutRouter.enable
    spin_group = CLI::UI::SpinGroup.new
    spin_group.add(roll.roll_number) do
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
    end
    spin_group.wait
    `touch source/.generated`
  end
end



helpers do
  def thumb_path(path)
    path.sub(Analog::Config.path + "/" , "")
  end

  def asset(file)
    width, height = Dimensions.dimensions(File.join('source/images', thumb_path(file)))
    OpenStruct.new(file: thumb_path(file), width: width, height: height, ratio: width.to_f / height.to_f)
  end

end

