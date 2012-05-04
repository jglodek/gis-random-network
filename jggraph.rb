class JGGraph
	attr_accessor :nodes, :edges

	def initialize
		#wierzcholki
		@nodes = Array.new
		#tablica na krawedzie
		@edges = Array.new
	end

	def add_nodes(argument)
		case argument
			when Array
				@nodes += argument
			when Fixnum
				st = 0
				st = @nodes[@nodes.length-1] if @nodes.length>0
				for i in 0...argument
					@nodes.push st
					st+=1
				end
			else
				raise ArgumentError.new("wrong argument class: '#{argument.class.to_s}' only Fixnum or Array")
		end
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
			self.add_nodes(args_hash[:node_count]) if args_hash[:node_count] != nil
			#prawdopodobienstwo istnienia krawedzi miedzy dwoma wierzcholkami
			probability = args_hash[:edge_probability]
			for i in 0...@nodes.size
				for j in i+1...@nodes.size
					@edges.push [@nodes[i],@nodes[j]] if rand<probability
				end
			end
		when :euclidean	#Generacja sieci euklidesowej - sieć odbiorników o zasięgu R
			self.add_nodes(args_hash[:node_count]) if args_hash[:node_count] != nil
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
						@edges.push [@nodes[i],@nodes[j]]
					end
				end
			end
		when :scale_free #Generacja sieci bezskalowej
			nodes_to_add = Array.new
			if args_hash[:node_count]!=nil
				for i in (@nodes.length+1)...(@nodes.length+1+args_hash[:node_count])
					nodes_to_add.push i
				end
			else
				raise ArgumentError.new(":node_count must be set!")
			end

			#jeżeli graf jest pusty dodajemy jeden wierzchołek aby koło fortuny działało
			if @nodes.empty?
				@nodes.push nodes_to_add.shift
			end

			#Budowa koła fortuny
			sum = 0
			wheel_of_fortune = []
			@nodes.each do |n|
				nd = node_degree(n)+1
				sum+=nd
				wheel_of_fortune.push [nd, n]
			end
			step = args_hash[:node_degree_increment_step]
			count = 0
			for i in 0...nodes_to_add.length do
				count+= 1+step
				#dodanie wierzchołka
				@nodes.push nodes_to_add[i]
				#dodawanie odpowiedniej ilości krawędzi za pomocą koła fortuny
				while count>0.0
					selected = rand(sum)
					index = -1
					while selected>0
						index+=1
						selected-=wheel_of_fortune[index][0]
					end
					@edges.push [wheel_of_fortune[index][1], nodes_to_add[i]]
					#uaktualnienie koła fortuny
					wheel_of_fortune.push [1, nodes_to_add[i]]
					node2_idx = wheel_of_fortune.index{ |x| x[1] == wheel_of_fortune[index][1] }
					wheel_of_fortune[node2_idx][0]+=1
					sum+=2
					count-=1
				end
			end
		when :small_world #Generacja sieci małego świata
			self.add_nodes(args_hash[:node_count]) if args_hash[:node_count] != nil
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
			node_degrees.push flat.count(@nodes[i])
		end
		degrees = node_degrees.uniq
		degrees.sort!
		degrees.each do |d|
			deg_dist[d] = node_degrees.count(d)
		end
		deg_dist
	end

	def node_degree(node)
		@edges.flatten.count(node)
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
		neighbours = []
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
