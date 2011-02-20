class SimpleCmsMedia < ActiveRecord::Base
  has_attachment :storage      => :s3,
                 :max_size     => 500.megabytes,
                 :path_prefix  => "cms/media"#,
                 #:thumbnails   => { :thumb => '75x75>' }
                 #:content_type => "",

  validates_as_attachment
end
