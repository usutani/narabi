class HomeController < ApplicationController
  @@messages = ["foo", "bar", "baz", "self"]
  @@instances = ["Alice", "Bob", "David"]
  
  before_filter :has_source_text?, :only => :parse_text_area
  
  def index
    session[:source_text] ||= "Alice->Bob: Authentication Request\nBob->Alice: Authentication Response"
  end
  
  def delete_all
    delete_all_objects
    redirect_to root_url
  end
  
  def add_test_items
    instances = add_basic_instances
    add_basic_messages(instances.first.id)
    redirect_to root_url
  end
  
  def add_random_instances
    order = next_instance_order
    3.times do |i|
      Instance.create([{ name: @@instances[i], order: order + i }])
    end
    redirect_to root_url
  end
  
  def add_random_messages
    add_basic_instances if Instance.count == 0
    instances = Instance.all
    
    to = instances.sample.id
    order = next_message_order
    3.times do
      from = to
      to = instances.sample.id
      Message.create([
        { from_id:  from, 
          to_id:    to, 
          body:     @@messages.sample, 
          order:    order  }])
      order = order + 1
    end
    redirect_to root_url
  end
  
  def parse_text_area
    delete_all_objects
    session[:source_text] = params[:source_text]
    parse_text params[:source_text]
    redirect_to root_url
  end
  
  private
  
  def has_source_text?
    unless params[:source_text]
      redirect_to root_url
      return
    end
    session[:parsed] = 1
  end
  
  def delete_all_objects
    Instance.delete_all
    Message.delete_all
  end
  
  def parse_text(text)
    text.each_line { |line|
      hash = parse_instances_and_message line
      create_objects(hash) if hash
    }
  end
  
  def parse_instances_and_message(text)
    text.strip!
    instances_and_message = text.scan(/[^:]+/)
    return nil if instances_and_message.length != 2

    instances = instances_and_message[0].scan(/[^->\s]+/)
    return nil if instances.length != 2

    Hash[ 
      :from => instances[0].strip, 
      :to => instances[1].strip, 
      :message => instances_and_message[1].strip]
  end
  
  def create_objects(hash)
    from = Instance.find_or_create_by_name(hash[:from])
    from.order ||= next_instance_order
    from.save
    to = Instance.find_or_create_by_name(hash[:to])
    to.order ||= next_instance_order
    to.save
    Message.create([
      { from_id:  from.id, 
        to_id:    to.id, 
        body:     hash[:message], 
        order:    next_message_order }])
  end
  
  def add_basic_instances
    order = next_instance_order
    instances = Instance.create([
      { name: @@instances[0], order: order + 0 }, 
      { name: @@instances[1], order: order + 1 }, 
      { name: @@instances[2], order: order + 2 }])
  end
  
  def next_instance_order
    if Instance.count > 0 then
      Instance.last.order + 1
    else
      0
    end
  end
  
  def add_basic_messages(id)
    order = next_message_order
    from_to = [[0, 1], [0, 2], [2, 0], [1, 1]]
    4.times do |i|
      Message.create([
        { from_id:  id + from_to[i][0], 
          to_id:    id + from_to[i][1], 
          body:     @@messages[i], 
          order:    order + i  }])
    end
  end
  
  def next_message_order
    if Message.count > 0 then
      Message.last.order + 1
    else
      0
    end
  end
end
