xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.rsp 'status_code' => 0, 'status_message' => 'Success' do
  xml.daily_counts 'type' => 'Logins' do
    current = (Time.now.midnight) - 8.days
    0.upto 7 do |i|
      current += 1.day
      xml.count @logins[current.to_date.to_s(:db)].to_i, 'date' => current.to_s(:line_grapher)
    end
  end  
  xml.daily_counts 'type' => 'Comments' do
    current = (Time.now.midnight) - 8.days
    0.upto 7 do |i|
      current += 1.day
      xml.count @comments[current.to_date.to_s(:db)].to_i, 'date' => current.to_s(:line_grapher)
    end
  end  
  xml.daily_counts 'type' => 'Investigations' do
    current = (Time.now.midnight) - 8.days
    0.upto 7 do |i|
      current += 1.day
      xml.count @posts[current.to_date.to_s(:db)].to_i, 'date' => current.to_s(:line_grapher)
    end
  end  
  xml.daily_counts 'type' => 'Blanks' do
    current = (Time.now.midnight) - 8.days
    0.upto 7 do |i|
      current += 1.day
      xml.count @photos[current.to_date.to_s(:db)].to_i, 'date' => current.to_s(:line_grapher)
    end
  end  


end