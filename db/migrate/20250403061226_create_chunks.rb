class CreateChunks < ActiveRecord::Migration[7.2]
  def change
    create_table :chunks do |t|
      t.references :document, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :chunk_index
      t.vector :embedding, null: false, limit: 1536
      t.jsonb :metadata
      t.integer :token_count

      t.timestamps
    end
  end
end