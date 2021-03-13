db_config = YAML::load(File.open('config/database.yml'))

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(db_config)
