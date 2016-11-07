def approp_answer(pos_arr, neg_arr)
  loop do
    answer = gets.chomp.downcase
    if pos_arr.include?(answer)
      return 'positive'
    elsif neg_arr.include?(answer)
      return 'negative'
    else
      p "Please enter a valid choice"
    end
  end
end

approp_answer(['hit'], ['stay'])