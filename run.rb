require 'graphviz'
require 'sinatra'
require 'erb'

require './jggraph.rb'

get '/' do
	#wyswietlenie views/nowy.erb
	return erb :nowy
end

get '/jquery-1.7.1.min.js' do
  File.read('./views/jquery-1.7.1.min.js')
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

	@jggraph = JGGraph.new(node_num)

	case params[:graph_type]
	when "losowa"
		@jggraph.generate_network :random, :edge_probability=> beta.to_f
	when "euklides"
		@jggraph.generate_network :euclidean, :radius=> beta.to_f
	when "bezskalowa"
		@jggraph.generate_network :scale_free, :node_degree_increment_step => beta.to_f
	when "maly-swiat" #http://en.wikipedia.org/wiki/Watts_and_Strogatz_Model
		@jggraph.generate_network :small_world, :mean_degree => mean_degree, :rewiring_probability => beta.to_f
	end
	#czyszczenie grafu z wielokrotnych krawędzi i pętli
	@jggraph.clean_up

	#Rysowanie grafu GRAPHVIZ
	if @drawgraph
		g = GraphViz.new( :G,:use=>draw_engine, :type => :graph )
		#wierzcholki graphviz
		@gv_nodes = Array.new
		@jggraph.nodes.each do |n|
			nod = g.add_nodes( "#{n}" )
			@gv_nodes.push nod
			nod["shape"] = "point"
		end
		#krawedzie graphviz
		@jggraph.edges.each do |e|
			g.add_edges(@gv_nodes[e[0]],@gv_nodes[e[1]])
		end
		# rysowanie
		g.output( :jpeg => "./views/graf.jpeg")
	end

	#obliczanie rozkladu stopni
	@deg_dist = @jggraph.degree_distribution

	#wyswietlenie wynikow z pliku views/stats.erb
	return erb :stats
end

get '/graf.jpeg' do
  File.read('./views/graf.jpeg')
end
