class PasswordResetMailer
  @queue = :password_reset_mailer
  def self.perform(id)
    user = User.find(id)
    token = user.forgot_password_token
    UserMailer.password_reset(user, token).deliver
  end
end