class AddInitialDefaultScorers < ActiveRecord::Migration
  def up
    DefaultScorer.create(
      name: 'v2',
      scale: (0..1).to_a,
      code:
      "setScore(2.222);",
      decimal_places: 2,
      state: "published")
    DefaultScorer.create(
      name: 'v3',
      scale: (0..1).to_a,
      code:
      "setScore(2.22);",
      decimal_places: 1,
      state: "published")
  end
  def down
    DefaultScorer.where(name: 'v2').delete_all() 
    DefaultScorer.where(name: 'v3').delete_all()
  end
end
