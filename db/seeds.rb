# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

instances = Instance.create([
  { name: 'Alice', order: 0 }, 
  { name: 'Bob', order: 2 }, 
  { name: 'Davlid', order: 3 }])

message = Message.create([
  { from_id: 1, to_id: 2, body: 'foo', order: 0, is_return: false}, 
  { from_id: 1, to_id: 3, body: 'bar', order: 1, is_return: false }, 
  { from_id: 3, to_id: 1, body: 'baz', order: 2, is_return: true },
  { from_id: 2, to_id: 2, body: 'self', order: 3, is_return: false }])
