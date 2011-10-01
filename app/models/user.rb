class User < ActiveRecord::Base
  acts_as_authentic

  has_many :web_services

  def save_service_key1(name, value)
    save_key(name, :key1, value)
  end

  def save_service_key2(name, value)
    save_key(name, :key2, value)
  end

  def get_service_key1(name)
    srv = web_services.where(:name => name.to_s).first
    srv.blank? ? nil : srv.key1
  end

  def get_service_key2(name)
    srv = web_services.where(:name => name.to_s).first
    srv.blank? ? nil : srv.key2
  end

  def has_service?(name)
    !web_services.where(:name => name).blank?
  end

private

  def save_key(name, key, value)
    srv = web_services.find_or_create_by_name(name.to_s)
    srv.send("#{key.to_s}=", value)
    srv.save!
  end

end

