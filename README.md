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

for development autoreload

	gem install shotgun

### Usage

	ruby grapviz.rb
	open web browser at http://localhost:4567/

or for development:

	shotgun grapviz.rb
	open web browser at http://localhost:9393/

### License

http://creativecommons.org/licenses/by-sa/2.0/legalcode

http://creativecommons.org/licenses/by-sa/2.0/
