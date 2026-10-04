class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # ActiveAdmin/Ransack (admin-only) require an explicit allowlist of what is
  # searchable. Default to every column and association; models holding sensitive
  # columns (e.g. User) narrow this. ActiveStorage/internal join models are not
  # exposed in the admin UI, so this stays admin-scoped.
  def self.ransackable_attributes(_auth_object = nil)
    column_names
  end

  def self.ransackable_associations(_auth_object = nil)
    reflect_on_all_associations.map { |a| a.name.to_s }
  end
end
