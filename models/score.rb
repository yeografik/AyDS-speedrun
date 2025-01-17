class Score < Sequel::Model
  many_to_one :careers
  many_to_one :surveys

  def validate
    super
    errors.add(:survey_id, 'cannot be empty') unless survey_id
    errors.add(:career_id, 'cannot be empty') unless career_id
  end

  # create and save scores in db
  def self.create_scores(careers, survey_id)
    careers.each do |career|
      score = Score.new(career_id: career.id, survey_id: survey_id)
      if score.save # store score in database
        [201, { 'Location' => "scores/#{score.id}" }, 'Score succesfully created']
      else
        [500, {}, 'Internal Server Error']
      end
    end
  end

  # takes a survey and retunrs an array with all the scored careers
  def self.get_careers(survey)
    careers = []
    scores = survey.scores
    scores.each do |score|
      careers.append(Career.find(id: score.career_id))
    end
    careers
  end

  def self.count_query(first_date, last_date, career_name)
    parsed_fst_d = Date.parse(first_date) # get first date as Date
    parsed_lst_d = Date.parse(last_date)  # get last date as Date
    career_id = Career.find(name: career_name).id

    query = Score.where(created_at: parsed_fst_d..parsed_lst_d).where(career_id: career_id)
    # SELECT * FROM scores WHERE ((career_id = career_id) AND (created_at BETWEEN parsed_fst_d AND parsed_lst_d))
    query.count.to_s # lastly we make a count of the rows in query
  end
end
