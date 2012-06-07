class Instance < ActiveRecord::Base
  belongs_to :diagram
  has_many :messages

  validates :name, :order, :presence => true
  validates :order, :uniqueness => true

  def self.next_order(request)
    ci = Diagram.current(request).instances
    if ci.count > 0
      ci.maximum(:order) + 1
    else
      0
    end
  end
end
