class AddFloatToDefaultScorer < ActiveRecord::Migration
  def up
      add_column :default_scorers, :decimal_places, :tinyint, null: 0, default: 0
  end
  def down
    remove_column :default_scorers, :decimal_places, :tinyint, null: 0, default: 0
  end
end
