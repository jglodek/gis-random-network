class JGGraph
	attr_accessor :nodes, :edges

	def initialize(nodes_number)
		#wierzcholki
		@nodes = Array.new
		for i in 0...nodes_number do
			@nodes.push i
		end

		#tablica na krawedzie
		@edges = Array.new
	end

	def add_edge(v1,v2)
		@edges.push [v1, v2]
	end

	def clean_up
		#czyszczenie podwojnych krawedzi
		@edges.each do |e|
			e.sort!
		end
		@edges = @edges.uniq
		#czyszczenie petli
		@edges.delete_if{|e| e[0]==e[1]}
	end

	def generate_network(type, args_hash)
		case type
		when :random #Generacja sieci losowej 0 Erdos-Renyi
			#prawdopodobienstwo istnienia krawedzi miedzy dwoma wierzcholkami
			probability = args_hash[:edge_probability]
			for i in 0...@nodes.size
				for j in i+1...@nodes.size
					@edges.push [i,j] if rand<probability
				end
			end
		when :euclidean	#Generacja sieci euklidesowej - sieć odbiorników o zasięgu R
			r_test = args_hash[:radius]*args_hash[:radius] #zmienna pomocnicza do testowania odległości
			positions = Array.new
			for i in 0...@nodes.size
				positions.push [rand, rand]
			end
			for i in 0...@nodes.size
				for j in i+1...@nodes.size
					a = (positions[i][0]-positions[j][0])
					b = (positions[i][1]-positions[j][1])
					dist = a*a+b*b # odległość między punktami
					if dist < r_test
						@edges.push [i,j]
					end
				end
			end
		when :scale_free #Generacja sieci bezskalowej
			step = args_hash[:node_degree_increment_step]
			count = 0
			for i in 1...@nodes.size do
				@edges.push [@nodes[i], @nodes[rand(i)]]
				count+=step
				while count>1
					@edges.push [@nodes[i], @nodes[rand(i)]]
					count-=1
				end
			end
		when :small_world #Generacja sieci małego świata
			#tworzenia pierścienia wierzchołków o stopniu zadanym parametrem
			step = args_hash[:mean_degree]/2.0
			rewiring_probability = args_hash[:rewiring_probability]
			count = 0
			for i in 0...@nodes.size do
				count+=step
				k = 1
				while count>1
					count-=1
					@edges.push [@nodes[i], @nodes[(i-k) % @nodes.size]]
					k+=1
				end
			end
			#rewiring, losowa rekonfiguracja krawędzi z prawdopodobieństwem zadanym parametrem
			@edges.each do |e|
				if rand < rewiring_probability
					wybor = rand(@nodes.size)
					e[1] = @nodes[wybor]
				end
			end
		end
		return self
	end

	def degree_distribution
		deg_dist = Hash.new
		node_degrees = Array.new
		flat = @edges.flatten
		for i in 0...@nodes.length
			node_degrees.push flat.count(i)
		end
		degrees = node_degrees.uniq
		degrees.sort!
		degrees.each do |d|
			deg_dist[d] = node_degrees.count(d)
		end
		deg_dist
	end

	def mean_degree
		@edges.length.to_f*2/@nodes.length.to_f
	end

	def clustering_coefficient
		sum = 0
		@nodes.each do |n|
			sum+=node_clustering_coefficient(n)
		end
		sum/@nodes.size.to_f
	end

	def node_clustering_coefficient(node)
		neighbours = [node]
		@edges.each do |edge|
			if edge[0]==node or edge[1]==node
				neighbours.push edge[0] if edge[1]==node
				neighbours.push edge[1] if edge[0]==node
			end
		end
		return 0 if neighbours.size <= 1
		neighbours.sort
		neighbour_to_neigbour_edges_count = 0
		for i in 0...neighbours.size
			for j in (i+1)...neighbours.size
				if @edges.include? [i,j]
					neighbour_to_neigbour_edges_count+=1
				end
			end
		end
		clique_on_neigbours_edge_count = neighbours.size.to_f*(neighbours.size-1)/2
		neighbour_to_neigbour_edges_count/clique_on_neigbours_edge_count
	end
end
