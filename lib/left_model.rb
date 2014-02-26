class LeftModel < ActiveRecord::Base
  establish_connection(ENV['URL_CONNECTION_LEFT'])
end