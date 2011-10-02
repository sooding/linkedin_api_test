class WebService < ActiveRecord::Base
  LIST = [:linkedin, :twitter, :yahoo, :facebook]

  belongs_to :user
end

