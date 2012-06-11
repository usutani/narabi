class Diagram < ActiveRecord::Base
  has_many :instances, dependent: :delete_all
  has_many :messages, dependent: :delete_all

  attr_accessible :title

  def self.current(request)
    Diagram.find_or_create_by_mark(pseudo_user_id(request))
  end

  def self.pseudo_user_id(request)
    request.session_options[:id]
  end
end
