class User < ActiveRecord::Base
  include BCrypt

  def password
    @password ||= Password.new(passwordHash)
  end

  def password=(newPassword)
    @password = Password.create(newPassword)
    self.passwordHash = @password
  end

  def self.authorized?(email, password)
    user = User.where(email: email).first
    user.password == password
  end
end
