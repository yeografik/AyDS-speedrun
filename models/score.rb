class Score < Sequel::Model  
  many_to_one :careers
  many_to_one :surveys

  #takes a collection of careers and an id and creates a Score object with
  #the given survey_id and career, for each career in the collection 
  #self makes the method static so we don't need an instance to invoke it
  def self.create_scores(careers, survey_id)
    careers.each do |career|
      score = Score.new(career_id: career.id, survey_id: survey_id)
      if score.save  #store score in database
		    [201, {'Location' => "scores/#{score.id}"}, 'Score succesfully created']
		  else
		    [500, {}, 'Internal Server Error']
		  end
    end
  end

  #takes a survey and retunrs an array with all the scored careers
  def self.get_careers(survey)
    careers = Array.new
    scores = survey.scores
    scores.each do |score|
      careers.append(Career.find(id: score.career_id))
    end
    return careers
  end

  def self.count_query(first_date, last_date, career_name)
    #if any of the parameters is not provided we return null
    if first_date.nil? || last_date.nil? || career_name.nil? || career_name == "Carrera"
      return nil
    end

    parsed_fst_d = Date.parse(first_date) #get first date as Date
    parsed_lst_d = Date.parse(last_date)  #get last date as Date
    career_id = Career.find(name: career_name).id
    
    query = Score.where(:created_at => parsed_fst_d .. parsed_lst_d).where(:career_id => career_id)
    #SELECT * FROM scores WHERE ((career_id = career_id) AND (created_at BETWEEN parsed_fst_d AND parsed_lst_d))
    return query.count.to_s #lastly we make a count of the rows in query
  end
end
