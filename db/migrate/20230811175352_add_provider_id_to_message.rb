class AddProviderIdToMessage < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :provider_id, :uuid

    add_index :messages, :provider_id, unique: true
  end
end
