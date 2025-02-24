class CreateDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :documents do |t|
      t.string :title
      t.text :content
      t.vector :embedding, null: false, limit: 1536

      t.timestamps
    end
  end
end
