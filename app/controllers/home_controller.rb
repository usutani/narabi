require 'narabi/parser'

class HomeController < ApplicationController
  @@messages = ["note", "foo", "bar", "baz", "self"]
  @@instances = ["Alice", "Bob", "David"]
  
  before_filter :has_source_text?, :only => :parse_text_area
  
  def index
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
        { from_id:    from, 
          to_id:      to, 
          body:       @@messages.sample, 
          order:      order, 
          is_return:  [true, false].sample,
          is_note:    [true, false].sample }])
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
  end
  
  def delete_all_objects
    Instance.delete_all
    Message.delete_all
  end
  
  def parse_text(text)
    text.each_line { |line| parse_instances_and_message line }
  end

  def parse_instances_and_message(text)
    text.strip!

    # instance Foo
    if instance = Narabi::Instance.parse_line(text)
      to = Instance.find_or_create_by_name(instance[:name].strip)
      to.order ||= next_instance_order
      to.save
      return
    end

    # note Foo: 123456789012345678901234567890
    if note = Narabi::Message.create_note(text)
      create_instances_and_message(note)
      return
    end

    pos = text.index(":")
    return if pos == nil
    left_side = text[0, pos]
    right_side = text[pos + 1, text.length - pos - 1]

    # Foo->Bar or Foo-->Bar
    instances = left_side.scan(/[^->\s]+/)
    if instances.length == 2
      create_instances_and_message(
        :from => instances[0].strip, 
        :to => instances[1].strip, 
        :message => right_side.strip, 
        :is_return => left_side.index("-->") != nil, 
        :is_note => false)
      return
    end
  end
  
  def create_instances_and_message(hash)
    from = Instance.find_or_create_by_name(hash[:from])
    from.order ||= next_instance_order
    from.save
    to = Instance.find_or_create_by_name(hash[:to])
    to.order ||= next_instance_order
    to.save
    Message.create([
      { from_id:    from.id, 
        to_id:      to.id, 
        body:       hash[:message], 
        order:      next_message_order,
        is_return:  hash[:is_return], 
        is_note:    hash[:is_note] }])
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
    from_to = [
      [0, 0, false, true], 
      [0, 1, false, false], 
      [0, 2, false, false], 
      [2, 0, true, false], 
      [1, 1, false, false]]
    5.times do |i|
      Message.create([
        { from_id:    id + from_to[i][0], 
          to_id:      id + from_to[i][1], 
          body:       @@messages[i], 
          order:      order + i,
          is_return:  from_to[i][2],
          is_note:    from_to[i][3] }])
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
