class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  enum :role, [:admin, :buyer, :seller]
  validates :role, :name, :phone_number, presence: true
  has_one_attached :avatar , dependent: :destroy
  has_one :cart, dependent: :destroy
  after_create :insert_avatar
  has_many :orders, dependent: :destroy
  has_many :products, dependent: :destroy
  after_create :create_cart
  has_many :addresses, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true
  has_many :bank_accounts, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :otps, dependent: :destroy


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
