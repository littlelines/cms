class CreateInquiries < ActiveRecord::Migration[5.0]
  def change
    create_table :push_type_inquiries do |t|
      t.string    :type
      t.string    :name
      t.string    :email
      t.jsonb     :field_store

      t.timestamps
    end
  end
end
