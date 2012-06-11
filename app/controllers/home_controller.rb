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
    current_diagram = Diagram.current(request)
    obj = current_diagram.instances.where(name: name).first
    unless obj
      obj = Instance.create
      obj.diagram = current_diagram
      obj.name = name
    end
    obj.order ||= Instance.next_order(request)
    obj.save!
    obj
  end

  def create_instances_and_message(hash)
    obj = Message.create
    obj.diagram = Diagram.current(request)
    obj.from = create_instance(hash[:from])
    obj.to = create_instance(hash[:to])
    obj.body = hash[:body]
    obj.order = Message.next_order(request)
    obj.is_return = hash[:is_return]
    obj.is_note = hash[:is_note]
    obj.save!
    obj
  end
end
