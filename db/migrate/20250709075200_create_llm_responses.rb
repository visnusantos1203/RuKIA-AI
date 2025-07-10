class CreateLlmResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :llm_responses do |t|
      t.belongs_to :message, null: false, foreign_key: true
      t.string :body, null: false
      t.integer :token_count
      t.string :persona
      t.string :source

      t.timestamps
    end
  end
end
