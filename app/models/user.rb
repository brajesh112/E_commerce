class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  enum :role, [:admin, :buyer, :seller]
  validates :role, presence: true
  has_one_attached :avatar


  def admin?
  	self.role.eql?('admin')
  end

  def buyer?
  	self.role.eql?('buyer')
  end

  def seller?
  	self.role.eql?('seller')
  end
end
