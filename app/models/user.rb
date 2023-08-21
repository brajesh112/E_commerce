class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  enum :role, [:admin, :buyer, :seller]
  validates :role, presence: true
  has_one_attached :avatar
  has_one :cart
  after_create :insert_avatar
  has_many :orders
  has_many :products
  after_create :create_cart

  def insert_avatar
      unless self.avatar.attached? 
      self.avatar.attach(io: File.open("#{Rails.root}/app/assets/images/profile.png"), filename: 'profile.png', content_type: 'image/png')
    end
  end

  def create_cart
    self.cart = Cart.create()
  end
  
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
