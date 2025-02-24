class EnablePgvectorExtension < ActiveRecord::Migration[7.2]
  def change
    begin
      enable_extension :vector
    rescue Exception => e
      Rails.logger.error "Failed to enable 'pgvector' extension: #{e.class} - #{e.message}"

      if ActiveRecord::Base.connection.execute("SELECT 1 FROM pg_available_extensions WHERE name = 'vector';").empty?
        Rails.logger.error "The 'pgvector' extension is not available in the database. Ensure it is installed and enabled before proceeding."
      end

      raise ActiveRecord::MigrationError, "Migration failed: Unable to enable 'pgvector' extension. Check logs for details."
    end
  end
end
