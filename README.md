GIS random network
==================

GIS - graphs and networks

Generating random networks

* Random network - Erdős–Rényi model
* Random Euclidean network - network of ⟨0,1⟩∗⟨0,1⟩ ∈ R² points, connected if close enough (radius parameter)
* Random scale-free network - modified Barabási–Albert model
* Random small-world network - Watts-Strogatz model

### Requirements

	Ruby 1.9.3
	Ruby Gems

	gem install sinatra
	gem install ruby-graphviz
	gem install erb

for development autoreload and tests

	gem install minitest
	gem install shotgun

### Usage

for generator app:

	ruby run.rb
	open web browser at http://localhost:4567/

for lib:

	require './jggraph.rb'

	g = JGGraph.new(100) #new graph with 100 nodes

	#generate random network Erdős–Rényi model
	g.generate_network :random, :edge_probability => 0.1

	#generate random Euclidean network
	g.generate_network :euclidean, :radius => 0.2

	#generate random scale-free network
	g.generate_network :scale_free, :node_degree_increment_step => 0.01

	#generate random small-world network
	g.generate_network :small_world, :mean_degree => 6, :rewiring_probability => 0.01

	#clean up duplicated edges and loops
	g.clean_up

	#mean degree of the graph
	g.mean_degree
	#=> 4.98

	#degree distribution of the graph
	g.degree_distribution
	#=> {0=>5, 1=>10, 2=>4, 3=>2}

	#clustering coefficient of the graph (slow)
	g.clustering_coefficient

	#node clustering coefficient
	g.node_clustering_coefficient(node)

	#list of nodes
	g.nodes

	#list of edges
	g.edges

or for development of frontend:

	shotgun run.rb
	open web browser at http://localhost:9393/

or for testing (rspec!) and development of library:

	ruby test/jggraph-test.rb

### License

http://creativecommons.org/licenses/by-sa/2.0/legalcode

http://creativecommons.org/licenses/by-sa/2.0/
