namespace :simple_cms do
  desc "take the simple cms work from development database and place in production"
  task :push_to_prod => :environment do
    SimpleCmsItem.establish_connection :development
    SimpleCmsImage.establish_connection :development
    SimpleCmsMedia.establish_connection :development
    items  = SimpleCmsItem.find(:all)
    images = SimpleCmsImage.find(:all)
    medias = SimpleCmsMedia.find(:all)

    SimpleCmsItem.establish_connection :production
    SimpleCmsImage.establish_connection :production
    SimpleCmsMedia.establish_connection :production
    SimpleCmsItem.transaction do
      items.each{|item| item.clone.save}
      medias.each{|media| media.clone.save}
      images.each{|image| image.clone.save}
    end
  end

  desc "get the differences between production and development"
  task :diff_counts => :environment do
    SimpleCmsItem.establish_connection :development
    SimpleCmsImage.establish_connection :development
    SimpleCmsMedia.establish_connection :development
    puts "DEV SimpleCmsItem count: " + SimpleCmsItem.count.to_s
    puts "DEV SimpleCmsMedia count: " + SimpleCmsMedia.count.to_s
    puts "DEV SimpleCmsImage count: " + SimpleCmsImage.count.to_s
    
    SimpleCmsItem.establish_connection :production
    SimpleCmsImage.establish_connection :production
    SimpleCmsMedia.establish_connection :production
    puts "PROD SimpleCmsItem count: " + SimpleCmsItem.count.to_s
    puts "PROD SimpleCmsMedia count: " + SimpleCmsMedia.count.to_s
    puts "PROD SimpleCmsImage count: " + SimpleCmsImage.count.to_s
  end
end
