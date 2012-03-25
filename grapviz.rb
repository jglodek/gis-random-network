require 'graphviz'
require 'sinatra'
require 'erb'

get '/' do
	#wyswietlenie views/nowy.erb
	return erb :nowy
end

get '/jquery-1.7.1.min.js' do
  File.read('jquery-1.7.1.min.js')
end

get '/graf' do
	@par = params

	graph_type = params[:graph_type]
	node_num = params[:node_num].to_i
	mean_degree = params[:mean_degree].to_f
	beta = params[:beta].to_f
	draw_engine = params[:draw_engine]
	@drawgraph = params[:drawgraph]
	@neighbourhood = params[:neighbourhood]
	@showedges = params[:showedges]

	#wierzcholki
	@nodes = Array.new
	for i in 0...node_num do
		@nodes.push i
	end

	#tablica na krawedzie
	@edges = Array.new

	case params[:graph_type]
	when "losowa"
		probability = mean_degree/node_num
		for i in 0...node_num
			for j in i+1...node_num
				@edges.push [i,j] if rand<probability
			end
		end
	when "euklides"
		positions = Array.new
		for i in 0...node_num
			positions.push [rand, rand]
		end

	when "bezskalowa"
		step = beta
		count = 0
		for i in 1...node_num do
			@edges.push [@nodes[i], @nodes[rand(i)]]
			count+=step
			while count>1
				@edges.push [@nodes[i], @nodes[rand(i)]]
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
				@edges.push [@nodes[i], @nodes[(i-k)%node_num]]
				k+=1
			end
		end
		#rewiring
		@edges.each do |e|
			if rand < beta
				wybor = rand(node_num)
				e[1] = @nodes[wybor]
			end
		end
	end

	#czyszczenie podwojnych krawedzi
	@edges.each do |e|
		e.sort!
	end
	@final_edges = @edges.uniq
	#czyszczenie petli
	@final_edges.delete_if{|e| e[0]==e[1]}

	#Rysowanie grafu GRAPHVIZ
	if @drawgraph
		g = GraphViz.new( :G,:use=>draw_engine, :type => :graph )
		#wierzcholki graphviz
		@gv_nodes = Array.new
		@nodes.each do |n|
			nod = g.add_nodes( "#{n}" )
			@gv_nodes.push nod
			nod["shape"] = "point"
		end
		#krawedzie graphviz
		@final_edges.each do |e|
			g.add_edges(@gv_nodes[e[0]],@gv_nodes[e[1]])
		end
		# rysowanie
		g.output( :jpeg => "graf.jpeg")
	end

	#obliczanie rozkladu stopni
	node_degrees = Array.new
	@deg_dist = Hash.new
	flat = @final_edges.flatten
	for i in 0...@nodes.length
		node_degrees.push flat.count(i)
	end
	degrees = node_degrees.uniq
	degrees.sort!
	degrees.reverse!
	degrees.each do |d|
		@deg_dist[d] = node_degrees.count(d)
	end

	#wyswietlenie wynikow z pliku views/stats.erb
	return erb :stats
end

get '/graf.jpeg' do
  File.read('graf.jpeg')
end
