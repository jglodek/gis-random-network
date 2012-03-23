require 'graphviz'
require 'sinatra'
require 'erb'

get '/' do
	return erb :nowy
end

get '/jquery-1.7.1.min.js' do
  File.read('jquery-1.7.1.min.js')
end

get '/graf/:rodzaj/:ilosc' do

	rodzaj = params[:rodzaj]
	ilosc = params[:ilosc].to_i
	sredni_stopien_wierzcholka = 3
	beta = 0.01

	# Create a new graph
	g = GraphViz.new( :G,:use=> "twopi",:scale=>0.1, :type => :graph )

	case params[:rodzaj]
	when "losowa"
		nodes = Array.new
		for i in 0...ilosc do
			x = g.add_nodes("nod#{i}")
			x.set{|at| at.shape="point"}
			nodes.push x
		end
		ilosc_krawedzi = sredni_stopien_wierzcholka*ilosc/2
		for i in 0...ilosc_krawedzi do
			g.add_edges(nodes[rand(ilosc)], nodes[rand(ilosc)])
		end
	when "euklides"
	when "bezskalowa"
		nodes = Hash.new
		nodes[0]=g.add_nodes("nod0")
		nodes[0]["shape"]="point"
		for i in 1...ilosc do
			nodes[i]=g.add_nodes("nod #{i}")
			g.add_edges(nodes[i], nodes[rand(i)])
			nodes[i].set{|n| n.shape="point"}
		end
	when "maly-swiat" #http://en.wikipedia.org/wiki/Watts_and_Strogatz_Model
		#ring lattice
		nodes = Array.new
		nodes.push g.add_nodes("nod0")
		for i in 1...ilosc do
			nodes.push g.add_nodes("nod#{i}")
			g.add_edges(nodes[i], nodes[i-1])
		end
		g.add_edges(nodes[0],nodes[ilosc-1])
	end

	# Generate output image
	g.output( :jpeg => "graf.jpeg")

end

get '/graf.jpeg' do
  File.read('graf.jpeg')
end



