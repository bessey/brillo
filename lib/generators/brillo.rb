class BrilloConfigGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../", __FILE__)

  desc "Create a dummy database crub configuration"
  def create_initializer_file
    copy_file "config/brillo-example.yml", "config/brillo.yml"
  end
end
