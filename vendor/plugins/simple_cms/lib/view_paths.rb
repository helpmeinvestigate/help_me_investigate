module SimpleCmsMod
  module ViewPaths
    def self.included(klas)
      # For Rails versions >= 2.1
      klas.append_view_path File.join(File.dirname(__FILE__), '..', 'app', 'views')
    end
  end
end
