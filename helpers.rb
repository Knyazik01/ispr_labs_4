def get_random_answer (count = 1)
  result = []
  count.times {result.push %w[Так Ні].sample}
  result
end

def generate_answers_hash (hash)
  result = {}
  hash.entries.each do |key, questions_by_temperament|
    result[key] = get_random_answer(questions_by_temperament.length)
  end
  result
end

def generate_answers (hash, filename = 'answers')
  answers = generate_answers_hash hash
  File.write("./json/#{filename}.json", JSON.pretty_generate(answers))
end