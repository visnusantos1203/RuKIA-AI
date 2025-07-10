class AddUserRefToDocument < ActiveRecord::Migration[7.2]
  def change
    add_reference :documents, :user, null: false, foreign_key: true
  end
end
