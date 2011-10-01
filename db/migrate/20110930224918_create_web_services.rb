class CreateWebServices < ActiveRecord::Migration
  def change
    create_table :web_services do |t|
      t.string :name
      t.string :key1
      t.string :key2
      t.references :user

      t.timestamps
    end
    add_index :web_services, :user_id
  end
end
