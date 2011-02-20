class SimpleCmsImage < ActiveRecord::Base
  has_attachment :content_type => :image,
                 :storage      => :s3,
                 :path_prefix  => "cms/image",
                 :max_size     => 2.megabytes,
                 :thumbnails   => { :thumb => '50x50>' }

  validates_as_attachment
end
