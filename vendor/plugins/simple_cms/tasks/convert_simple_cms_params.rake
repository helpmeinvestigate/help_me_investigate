#=> "--- !map:HashWithIndifferentAccess \nlabel: installation_guides\ndomain: new.riccobene.com\naction: index\ncontroller: installation_guides\n"
##>> SimpleCmsItem.all.map(&:params).select{|p| p =~ /installation/}[1]
##=> "--- !map:HashWithIndifferentAccess \ndomain: new.riccobene.com\naction: index\ncontroller: installation_guides\nlabel: installation_guides\n"
#
#
namespace :simple_cms do
  desc "convert param order for simple cms"
  task :convert => :environment do
    SimpleCmsItem.find(:all).each do |i|
      puts "===================  SIMPLE CMS ITEM #{i.id} ==============================="
      puts "CURRENT PARAMS: #{i.params.inspect}"
      begin
        a = YAML.load(i.params)
      rescue
        puts "ERROR lodaing simple cms item params ... probably an outdated simple cms item."
        next
      end
      puts "CURRENT ARRAY CONTENT: #{a.inspect}"
      #begin
      #  h = Hash[*a.flatten] 
      #rescue 
      #  puts "ERROR Converting array to hash ... probably an outdated simple cms item."
      #  next
      #end
      h = a
      puts "CURRENT HASH CONTENT #{h.inspect}"
      h.each do |x|
        if x[0] =~ /domain/
          puts "CURRENT DOMAIN: #{x[1]}"
          x[1] = ENV["NEW_DOMAIN"] if ENV["NEW_DOMAIN"]
          puts "NEW DOMAIN: #{x[1]}"
        end
      end
      puts "NEW HASH CONTENT #{h.inspect}"
      a = h.to_a
      puts "NEW ARRAY CONTENT: #{a.inspect}"
      a = a.sort{|a,b| a.to_s <=> b.to_s}
      puts "OLD PARAMS: #{i.params.inspect}"
      i.update_attributes(:params => a.to_yaml)
      puts "NEW PARAMS: #{i.params.inspect}"
    end
  end
end
