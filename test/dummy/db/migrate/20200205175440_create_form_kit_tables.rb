# frozen_string_literal: true

class CreateFormKitTables < ActiveRecord::Migration[6.0]
  def change
    create_table :form_kit_forms do |t|
      t.references :attachable, polymorphic: true

      t.string :name

      t.string :key, null: false, index: { unique: true }

      t.string :type, null: false

      t.timestamps
    end

    create_table :form_kit_fields do |t|
      t.references :form, null: false, foreign_key: { to_table: :form_kit_forms }

      t.string :name
      t.string :hint

      t.string :key, null: false
      t.index %i[form_id key], unique: true

      t.text :validations
      t.text :options
      t.integer :accessibility, null: false
      t.text :default_value
      t.integer :position, null: false, default: 0

      t.string :type, null: false

      t.timestamps
    end

    create_table :form_kit_choices do |t|
      t.references :form, null: false, foreign_key: { to_table: :form_kit_forms }
      t.references :field, null: false, foreign_key: { to_table: :form_kit_fields }

      t.text :label, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    create_table :form_kit_form_overrides do |t|
      t.references :form, null: false, foreign_key: { to_table: :form_kit_forms }
      t.integer :position, null: false, default: 0
      t.string :name

      t.timestamps
    end

    create_table :form_kit_field_overrides do |t|
      t.references :form_override, null: false, foreign_key: { to_table: :form_kit_form_overrides }
      t.references :field, null: false, foreign_key: { to_table: :form_kit_fields }
      t.index %i[form_override_id field_id], unique: true, name: "index_form_kit_field_overrides_on_form_field_id"

      t.integer :accessibility, null: false

      t.timestamps
    end
  end
end
