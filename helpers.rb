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

def check_temperament_type(percent)
  if percent >= 40
    'домінуючий'
  elsif 30 <= percent && percent < 40
    'виражений яскраво'
  elsif 20 <= percent && percent < 30
    'середній'
  elsif 10 <= percent && percent < 20
    'слабо вижений'
  else
    'виражений дуже слабо'
  end
end
def generate_final_message (percents_by_section, names)
  percent_len = (percents_by_section.max_by {|_key, value| value.to_s.length})[1].to_s.length
  name_len = (names.max_by {|_key, name| name.length})[1].length

  messages_array = percents_by_section
  .entries
  .sort { |entries1, entries2| entries2[1] <=> entries1[1] }
  .map do |temperament, percent|
    temperament_name = names[temperament].ljust(name_len)
    percent_value = (percent.to_s + '%').rjust(percent_len + 1) # add '%' symbol
    "Ви #{temperament_name} на #{percent_value} (#{check_temperament_type percent})"
  end

  max_message_len = messages_array.max { |a, b| a.length <=> b.length }.length

  messages = messages_array.map { |line| '| ' + (line.ljust(max_message_len)) + ' |' }

  border_line = '-'*(max_message_len + 4) # border + spase

  border_line + "\n" + messages.join("\n") + "\n" + border_line
end