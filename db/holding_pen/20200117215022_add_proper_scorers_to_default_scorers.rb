class AddProperScorersToDefaultScorers < ActiveRecord::Migration
  def up
    DefaultScorer.create(
      name: 'RR',
      scale: (0..1).to_a,
      code:
      "let i = 0;
      while (hasDocRating(i)) {
          if (docRating(i) == 1) {
              let score = 1 / (i + 1);
              setScore(score);
          }
          i++;
      }
      setScore(1/0);",
      decimal_places: 2,
      state: "published")
    DefaultScorer.create(
      name: 'P@5',
      scale: (0..1).to_a,
      code:
      "let at_rank = 5;
      let score = avgRating(at_rank);
      setScore(score);",
      decimal_places: 2,
      state: "published")
    DefaultScorer.create(
      name: 'AP@5',
      scale: (0..1).to_a,
      code:
      "let at_rank = 5;
      let scores = [];
      eachDoc(function(doc, i) {
          scores.push(avgRating(i));
      }, at_rank); 
      let score = scores.reduce((a, b) => a + b, 0) / at_rank;
      setScore(score);",
      decimal_places: 2,
      state: "published")
      DefaultScorer.create(
        name: 'CG@5',
        scale: (0..4).to_a,
        code:
        "let at_rank = 5;
        let scores = [];
        eachDoc(function(doc, i) {
            scores.push(avgRating(i));
        }, at_rank);
        console.log(scores);
        let score = scores.reduce((a, b) => a + b, 0);
        setScore(score);",
        decimal_places: 0,
        state: "published")
      DefaultScorer.create(
        name: 'DCG@5',
        scale: (0..4).to_a,
        code:
        "//  Implementation #2 https://en.wikipedia.org/wiki/Discounted_cumulative_gain#Discounted_Cumulative_Gain
        // Uses gain function: 2^grade - 1
        // Uses penalty function: log2(rank + 1)
        
        let at_rank = 5
        let scores = [];
        
        function position_calc(grade, rank) {
            let val = (2**grade - 1) / Math.log2(rank + 1);
            return val;
        }
        
        eachDoc(function(doc, i) {
            scores.push(position_calc(docRating(at_rank), at_rank + 1)); // i is JSindex not rank; 0 vs 1
        }, 5)
        
        let score = scores.reduce((a, b) => a + b, 0);
        setScore(score);",
        decimal_places: 1,
        state: "published")
  end
  def down
    DefaultScorer.where(name: 'RR').delete_all() 
    DefaultScorer.where(name: 'P@5').delete_all()
    DefaultScorer.where(name: 'AP@5').delete_all()
    DefaultScorer.where(name: 'CG@5').delete_all()
    DefaultScorer.where(name: 'DCG@5').delete_all()
  end
end
