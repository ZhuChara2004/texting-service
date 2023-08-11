class CreatePhoneNumbers < ActiveRecord::Migration[7.0]
  def change
    create_enum :phone_number_statuses, %i[active inactive]

    create_table :phone_numbers do |t|
      t.uuid :public_id
      t.string :number
      t.enum :status, enum_type: :phone_number_statuses, null: false, default: "active"

      t.timestamps
    end

    add_index :phone_numbers, :number, unique: true
  end
end
