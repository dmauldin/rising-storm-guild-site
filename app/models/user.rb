# == Schema Information
# Schema version: 20090302152543
#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
#  email              :string(255)
#  encrypted_password :string(128)
#  salt               :string(128)
#  token              :string(128)
#  token_expires_at   :datetime
#  email_confirmed    :boolean(1)      not null
#  admin              :boolean(1)      not null
#

class User < ActiveRecord::Base
  include Clearance::App::Models::User

  def admin?
    self.admin
  end
end
