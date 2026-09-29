class User < ApplicationRecord
  has_secure_password

  EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\z/

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                     format: { with: EMAIL_FORMAT }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
