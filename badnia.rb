
require './jggraph.rb'
[10,25,50,100,250,500,1000].each do |n|
	(0...5).each do
		g = JGGraph.new(n)
		g.generate_network :small_world, :mean_degree=>5, :rewiring_probability=>0.1
		g.clean_up
		puts "#{n} => #{g.clustering_coefficient}"
	end
end
