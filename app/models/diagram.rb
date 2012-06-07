class Diagram < ActiveRecord::Base
  has_many :instances
  has_many :messages

  attr_accessible :title

  def self.current(request)
    Diagram.find_or_create_by_mark(pseudo_user_id(request))
  end

  def self.pseudo_user_id(request)
    request.session_options[:id]
  end
end
