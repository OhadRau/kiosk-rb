class User < ActiveRecord::Base
  include BCrypt

  def password
    @password ||= Password.new(passwordHash)
  end

  def password=(newPassword)
    @password = Password.create(newPassword)
  end
end
