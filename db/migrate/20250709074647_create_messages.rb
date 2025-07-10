class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.belongs_to :document, null: false, foreign_key: true
      t.string :body, null: false
      t.vector :embedding, null: false, limit: 1536
      t.integer :token_count

      t.timestamps
    end
  end
end
