class Message < ActiveRecord::Base
  belongs_to :from, :class_name => 'Instance', :foreign_key => 'from_id'
  belongs_to :to, :class_name => 'Instance', :foreign_key => 'to_id'
  
  validates :from, :to, :body, :order, :presence => true
  validates :order, :uniqueness => true
end
