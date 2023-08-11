class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_enum :message_statuses, %i[pending delivered failed invalid]

    create_table :messages do |t|
      t.uuid :public_id
      t.string :body
      t.enum :status, enum_type: :message_statuses, null: false, default: "pending"
      t.belongs_to :phone_number, null: false, foreign_key: true

      t.timestamps
    end

    add_index :messages, :public_id, unique: true
  end
end
