require 'narabi/parser'

class HomeController < ApplicationController
  before_filter :prepare_diagram
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

  def prepare_diagram
    Diagram.current(request)
  end

  def has_source_text?
    unless params[:source_text]
      redirect_to root_url
      return
    end
  end

  def delete_all_objects
    Diagram.current(request).instances.delete
    Message.delete_all
    Diagram.current(request).delete
  end

  def parse_text(text)
    text.each_line { |line| parse_instances_and_message line }
  end

  def parse_instances_and_message(text)
    text.strip!

    if instance = Narabi::Instance.parse_line(text)
      create_instance(instance[:name].strip)
      return
    end

    if instances = Narabi.parse_line(text)
      create_instances_and_message(instances)
      return
    end

    if diagram = Narabi::Diagram.parse_line(text)
      obj = Diagram.current(request)
      obj.title = diagram[:title].strip
      obj.save
      return
    end
  end

  def create_instance(name)
    obj = Instance.find_or_create_by_name(name)
    obj.diagram = Diagram.current(request)
    obj.order ||= Instance.next_order(request)
    obj.save
    obj
  end

  def create_instances_and_message(hash)
    from = create_instance(hash[:from])
    to = create_instance(hash[:to])
    Message.create(
      { from_id:    from.id,
        to_id:      to.id,
        body:       hash[:body],
        order:      next_message_order,
        is_return:  hash[:is_return],
        is_note:    hash[:is_note] })
  end

  def next_message_order
    if Message.count > 0
      Message.last.order + 1
    else
      0
    end
  end
end
