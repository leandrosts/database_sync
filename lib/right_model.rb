class RightModel < ActiveRecord::Base
  establish_connection(ENV['URL_CONNECTION_RIGHT'])
end