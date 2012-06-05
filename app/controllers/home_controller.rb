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

    if instance = Narabi::Instance.parse_line(text)
      to = Instance.find_or_create_by_name(instance[:name].strip)
      to.order ||= next_instance_order
      to.save
      return
    end

    if instances = Narabi.parse_line(text)
      create_instances_and_message(instances)
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
    Message.create(
      { from_id:    from.id,
        to_id:      to.id,
        body:       hash[:body],
        order:      next_message_order,
        is_return:  hash[:is_return],
        is_note:    hash[:is_note] })
  end

  def next_instance_order
    if Instance.count > 0 then
      Instance.last.order + 1
    else
      0
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
