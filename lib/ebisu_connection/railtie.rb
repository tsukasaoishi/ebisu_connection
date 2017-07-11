module EbisuConnection
  class Railtie < Rails::Railtie
    initializer "fresh_connection.initialize_database", after: "active_record.initialize_database" do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.establish_fresh_connection
      end
    end
  end
end
