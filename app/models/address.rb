class Address < ApplicationRecord
	belongs_to :user
	has_many :orders, dependent: :destroy
	validates  :house_no, :street, :landmark,:country, :pin, presence: true

  # state has to be valid when changing a country
  validates :state, inclusion: { in: ->(record) { record.state_opts.keys }, allow_blank: true }
  validates :state, presence: { if: ->(record) { record.state_opts.present? } }

  # some countries don't have any cities, like Vatican.
  # city has to be valid when changing a country/state
  validates :city, inclusion: { in: ->(record) { record.city_opts }, allow_blank: true }
  validates :city, presence: { if: ->(record) { record.city_opts.present? } }

  def country_opts
    CS.countries.with_indifferent_access
  end

  def state_opts
    CS.states(country).with_indifferent_access
  end

  def city_opts
    CS.cities(state, country) || []
  end

  def country_name
    country_opts[country]
  end

  def state_name
    state_opts[state]
  end
end