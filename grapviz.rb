require 'graphviz'
require 'sinatra'
require 'erb'

get '/' do
	return erb :nowy
end

get '/jquery-1.7.1.min.js' do
  File.read('jquery-1.7.1.min.js')
end

get '/graf' do
	graph_type = params[:graph_type]
	node_num = params[:node_num].to_i
	mean_degree = params[:mean_degree].to_f
	beta = params[:beta].to_f
	# Create a new graph
	g = GraphViz.new( :G,:use=>"neato", :type => :graph )

	#wierzcholki
	nodes = Array.new
	for i in 0...node_num do
		nod = g.add_nodes( "n#{i}")
		nod["shape"] = "point"
		nodes.push nod
	end

	#tablica na krawedzie
	edges = Array.new

	case params[:graph_type]
	when "losowa"
		for i in 0...node_num

		end
	when "euklides"
	when "bezskalowa"
		step = beta-1
		count = 0
		for i in 1...node_num do
			g.add_edges(nodes[i], nodes[rand(i)])
			count+=step
			while count>1
				g.add_edges(nodes[i], nodes[rand(i)])
				count-=1
			end
		end
	when "maly-swiat" #http://en.wikipedia.org/wiki/Watts_and_Strogatz_Model
		#polaczenia ring-latice
		step = mean_degree.to_f/2.0
		count = 0
		for i in 0...node_num do
			count+=step
			k = 1
			while count>1
				count-=1
				edges.push [nodes[i], nodes[(i-k)%node_num]]
				k+=1
			end
		end
		#rewiring
		edges.each do |e|
			if rand < beta
				wybor = rand(node_num)
				e[1] = nodes[wybor]
			end
		end
	end

	#czyszczenie podwojnych krawedzi
	final_edges = edges
	edges.each do |e|
		#petla
		if e[0]==e[1]
			final_edges = final_edges - [e]
		else
			edges.each do |f|
				if e!=f
					#taka sama
					if e[0]==f[0] && e[1] == f[1]
						final_edges = final_edges - [f]
					end
					#odwrotna
					if e[0]==f[1] && e[1] ==f[0]
						final_edges = final_edges - [f]
					end
				end
			end
		end
	end

	#krawedzie
	final_edges.each do |e|
		g.add_edges(e[0],e[1])
	end

	# Generate output image
	g.output( :jpeg => "graf.jpeg")
	return erb :stats
end

get '/graf.jpeg' do
  File.read('graf.jpeg')
end
