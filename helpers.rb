def get_random_answer (questions)
  result = {}
  questions.each { |question| result[question] = %w[Так Ні].sample }
  result
end

def generate_answers_hash (hash)
  result = {}
  hash.entries.each do |key, questions_by_temperament|
    result[key] = get_random_answer(questions_by_temperament)
  end
  result
end

def generate_answers (hash, filename = 'answers')
  answers = generate_answers_hash hash
  File.write("./json/#{filename}.json", JSON.pretty_generate(answers))
end

def get_answer (question)
  puts question
  answer = gets.chomp.downcase
  is_valid = %w[так ні].include?(answer.downcase)
  if is_valid
    answer
  else
    puts "Введіть так або ні"
    get_answer question
  end
end

def get_answers (questions_hash)
  # select answer mode
  puts "Оберіть тип надання відповідей:\n1. Вручну\n2. У файлі за шляхом ./json/answers.json"
  answer_mode = gets.chomp.to_i
  if answer_mode === 1
    answers = {}
    puts "Надайте відповіді на запитання"
    questions_hash.entries.each_with_index do |entries, index|
      section, section_questions = entries
      puts "Секція #{index + 1}"
      section_questions.each do |current_question|
        answer = get_answer current_question
        if answers[section].kind_of?(Hash)
          answers[section][current_question] = answer
        else
          answers[section] = {}
          answers[section][current_question] = answer
        end
      end
    end
    # save user answers in file
    File.write("./json/answers.json", JSON.pretty_generate(answers))
    answers
  elsif answer_mode === 2
    answers_file = File.read('./json/answers.json')
    JSON.parse(answers_file)
  else
    puts "Оберіть правильний тип"
    get_answers questions_hash
  end
end