puts "All instance id's from global search:"
puts esor_search('name','app')

puts "All instances name's with ardsi in the Name tag:"
puts esor_search('name','ardsi','name')

puts "All instance name's that start with r:"
puts esor_search('name','^r','name')
