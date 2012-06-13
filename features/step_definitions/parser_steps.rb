Given /^the client posts following text:$/ do |text|
  @text = text
end

When /^the system parse posted text$/ do
  post "/home/parse_text", source_text: @text
end

Then /^the system should have <(\d+)> instances and <(\d+)> messages$/ do |expected_instances, expected_messages|
  Instance.count.should == expected_instances.to_i
  Message.count.should == expected_messages.to_i
end

Then /^the system should create following instances:$/ do |table|
  table.hashes.each do |obj|
    Instance.find_by_order(obj[:order]).name.should == obj[:name]
  end
end

Then /^the system should create following messages:$/ do |table|
  table.hashes.each do |obj|
    Message.find_by_order(obj[:order]).body.should == obj[:body]
  end
end
