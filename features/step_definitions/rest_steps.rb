Given /^the system knows about the following instances:$/ do |instances|
  get("/")
  Diagram.count.should == 1
  attrs = instances.hashes.map { |a| a.merge(diagram: Diagram.first) }
  Instance.create!(attrs, without_protection: true)
  Instance.count.should == 2
end

When /^the client requests GET (.*)$/ do |path|
  get(path)
  Diagram.count.should == 1
end

Then /^the response should be JSON:$/ do |json|
  res = JSON.parse(last_response.body).map do |h|
    h.delete("id")
    h.delete("created_at")
    h.delete("updated_at")
    h.delete("diagram_id")
    h
  end
  JSON.dump(res).should == json.gsub(/\s/, "")
end
