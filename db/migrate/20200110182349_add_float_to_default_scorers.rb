class AddFloatToDefaultScorers < ActiveRecord::Migration
  def change
      add_column :default_scorers, :b_float, :boolean, null: false, default: false 
  end
end
