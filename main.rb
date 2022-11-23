require 'json'
require './helpers'

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
        if answers[section].kind_of?(Array)
          answers[section].push answer
        else
          answers[section] = [answer]
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

# read questions
questions_file = File.read('./json/questions.json')
questions = JSON.parse(questions_file)

# generate answers
should_generate_answers = get_answer('Згенерувати відповіді? Так|Ні') === 'так'
should_generate_answers && generate_answers(questions)

# get answers
answers = get_answers questions

# calc yes answers
yes_by_section = {}
answers.entries.each do |temperament, temperament_answers|
  positive_count = temperament_answers.select { |answer| answer.chomp.downcase === 'так' }.count
  yes_by_section[temperament] = positive_count
end

all_yes_count = yes_by_section.values.reduce(0) do |yes_count, yes_for_temperament|
  yes_count + yes_for_temperament
end

# calc percents
percents = {}
yes_by_section.keys.each do |key|
  percent = (yes_by_section[key].to_f / all_yes_count) * 100
  percents[key] = percent.round(2)
end

# log results
temperament_names = {
"choleric" => "холерик",
"melancholic" => "сангвінік",
"phlegmatic" => "флегматик",
"sanguine" => "меланхолік",
}

name_len = (temperament_names.max_by {|_key, name| name.length})[1].length
percent_len = (percents.max_by {|_key, value| value.to_s.length})[1].to_s.length

result = percents
.entries
.sort { |entries1, entries2| entries2[1] <=> entries1[1] }
.map do |temperament, percent|
  temperament_name = temperament_names[temperament].ljust(name_len)
  percent_value = (percent.to_s + '%').rjust(percent_len + 1) # add '%' symbol
  "Ви #{temperament_name} на #{percent_value}"
end
.join "\n"

print "\n", '-----------------------------', "\n"
print result
print "\n", '-----------------------------', "\n"

File.write("./result.txt", result)
