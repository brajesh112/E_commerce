# Gives a taxonomy model a stable, unique `code` used by the bulk product
# importer. Auto-generated from a name attribute when blank.
module Codeable
  extend ActiveSupport::Concern

  included do
    before_validation :assign_code, on: :create
    validates :code, presence: true, uniqueness: true
  end

  class_methods do
    # The attribute to derive the code from (e.g. :name, :categories_type).
    def code_source(attr)
      @code_source = attr
    end

    def code_source_attr
      @code_source
    end
  end

  private

  def assign_code
    return if code.present?

    base = public_send(self.class.code_source_attr).to_s.parameterize(separator: "_").upcase
    base = "CODE" if base.blank?
    candidate = base
    i = 1
    while self.class.exists?(code: candidate)
      candidate = "#{base}_#{i}"
      i += 1
    end
    self.code = candidate
  end
end
