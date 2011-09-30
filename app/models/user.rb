class User < ActiveRecord::Base
  acts_as_authentic

  has_one  :linkedin, :class_name => 'LinkedinToken', :dependent => :destroy
end

