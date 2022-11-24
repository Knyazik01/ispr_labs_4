require 'json'
require './helpers'

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
  positive_count = temperament_answers.values.select { |answer| answer.chomp.downcase === 'так' }.count
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
"section_1" => "холерик",
"section_2" => "сангвінік",
"section_3" => "флегматик",
"section_4" => "меланхолік",
}

result = generate_final_message(percents, temperament_names)

print result

File.write("./result.txt", result)
