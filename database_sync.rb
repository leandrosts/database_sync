#!/usr/bin/env ruby

require 'dotenv'
Dotenv.load

require 'thor'
require 'active_record'
require Dir.pwd + '/lib/left_model.rb'
require Dir.pwd + '/lib/right_model.rb'

module Database
  class Sync < Thor
    
    desc 'sync', 'synchronize tables between two databases'
    def sync
      tables = ENV['TABLES'].split(',')
      log("Tables to sync: #{tables.join(', ')}")

      tables.each do |table|
        log("Processing table '#{table}'...")
        
        left_models_ids = []
        total_records = 0
        created_records = 0
        deleted_records = 0
        
        LeftModel.table_name = table
        RightModel.table_name = table
        model_right_attributes_names = RightModel.first.attribute_names

        LeftModel.order('id desc').each do |model|
          left_models_ids << model.id
          total_records += 1
          model_left_attributes = model.attributes.select{|key,_| model_right_attributes_names.include? key}
          
          if RightModel.exists?(model.id)
            RightModel.find(model.id).update_attributes(model_left_attributes)
          else
            created_records += 1
            m = RightModel.new
            m.assign_attributes(model_left_attributes)
            m.save
          end
        end

        deleted_records = RightModel.where("id not in (?)", left_models_ids).count()
        RightModel.where("id not in (?)", left_models_ids).delete_all
        
        log("Total: #{total_records} synced records")
        log("Created: #{created_records} records")
        log("Deleted: #{deleted_records} records")
        log("------------------------------------------")
      end
      log('Finished!')
    end

    private

    def log(message)
      puts "[database_sync] #{Time.now}: #{message}"
    end
  end
end

Database::Sync.start