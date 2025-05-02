class CreateDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :documents do |t|
      t.string :name, null: false        # Original filename
      t.string :file_type, null: false   # MIME type or file extension 
      t.text :description                # Optional description of the document
      t.integer :status                  # Processing status (uploaded, processed, error)
      t.boolean :is_active, default: true # Whether document is available for RAG
      t.integer :token_count

      t.timestamps
    end
  end
end
