Given /^there is a Help page$/ do
end

When /^I visit the page for Help$/ do
  visit("/help")
end

Then /^I should see "(.*?)" title$/ do |title|
  page.should have_content(title)
end

Then /^I should see "(.*?)" link$/ do |name|
  page.has_link?(name, href: root_path)
end
