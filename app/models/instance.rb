class Instance < ActiveRecord::Base
  has_many :messages
  
  validates :name, :order, :presence => true
  validates :order, :uniqueness => true
end
