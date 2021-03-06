class User < ActiveRecord::Base
  include Versions # version/user_version.rb
  devise :trackable, :timeoutable

  attr_accessor :phone

  def id_role_username
    "#{self.id}-#{self.class}: #{self.username}"
  end

end
