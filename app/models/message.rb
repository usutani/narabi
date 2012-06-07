class Message < ActiveRecord::Base
  belongs_to :diagram
  belongs_to :from, :class_name => 'Instance', :foreign_key => 'from_id'
  belongs_to :to, :class_name => 'Instance', :foreign_key => 'to_id'

  validates :from, :to, :order, :presence => true
  #TODO
  #validates :order, :uniqueness => true

  def self.next_order(request)
    obj = Diagram.current(request).messages
    if obj.count > 0
      obj.maximum(:order) + 1
    else
      0
    end
  end
end
