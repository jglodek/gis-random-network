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
	@par = params

	graph_type = params[:graph_type]
	node_num = params[:node_num].to_i
	mean_degree = params[:mean_degree].to_f
	beta = params[:beta].to_f

	@drawgraph = params[:drawgraph]
	@neighbourhood = params[:neighbourhood]
	# Create a new graph
	g = GraphViz.new( :G,:use=>"neato", :type => :graph )

	#wierzcholki
	@nodes = Array.new
	for i in 0...node_num do
		@nodes.push i
	end

	#tablica na krawedzie
	@edges = Array.new

	case params[:graph_type]
	when "losowa"
		for i in 0...node_num

		end
	when "euklides"
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

	#Rysowanie grafu
	if @drawgraph
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

	return erb :stats
end

get '/graf.jpeg' do
  File.read('graf.jpeg')
end
