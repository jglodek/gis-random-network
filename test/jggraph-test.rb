require 'minitest/autorun'
require './jggraph.rb'

describe JGGraph do
  before do
  	@graph = JGGraph.new(100)
  end

  describe "when constructed with parameter of one hunderd nodes" do
    it "should have one hundred nodes" do
    	assert @graph.nodes.size == 100
    end

    it "should have no edges" do
    	assert @graph.edges.size == 0
    end

    it "should have nodes each with degree 0" do
      assert @graph.degree_distribution == {0=>100}
    end
  end

  describe "when added some edges in tri edge cycle" do
    before do
      @graph.add_edge 0, 1
      @graph.add_edge 1, 2
      @graph.add_edge 2, 0
    end

    it "should have edges" do
      assert !@graph.edges.empty?
    end
    it "should have proper degree distribution" do
      assert @graph.degree_distribution == ({0=>97, 2=>3})
    end
  end

  describe "when generated random network" do
    it "should have no edges if probability equals 0" do
      (0..10).each do assert JGGraph.new(20).generate_network(:random, :edge_probability => 0).edges.empty? end
    end

    it "should be a full graph if probability equals 1" do
      (0..10).each do a = JGGraph.new(20).generate_network(:random, :edge_probability => 1).edges.size == 190 end
    end

    it "should have about N/2 edges if probability equals 0.5" do
      (0..10).each do assert JGGraph.new(20).generate_network(:random, :edge_probability => 0.5).edges.size - 95<20 end
    end
  end

  describe "when generated euclidean network" do
    it "should be a full graph when radius is set to 1.5" do
      (0..10).each do assert JGGraph.new(20).generate_network(:euclidean, :radius=>1.5 ).edges.size == 190 end
    end

    it "should have no edges with radius of 0" do
      (0..10).each do assert JGGraph.new(20).generate_network(:euclidean, :radius=>0 ).edges.empty? end
    end

    it "should be dense with radius of 0.8 to 1.5" do
      (0..10).each do
        graph = JGGraph.new(20).generate_network(:euclidean, :radius=>0.8 )
        assert graph.mean_degree>9
        graph = JGGraph.new(20).generate_network(:euclidean, :radius=>0.9 )
        assert graph.mean_degree>9
        graph = JGGraph.new(20).generate_network(:euclidean, :radius=>1.0 )
        assert graph.mean_degree>9
        graph = JGGraph.new(20).generate_network(:euclidean, :radius=>1.1 )
        assert graph.mean_degree>9
        graph = JGGraph.new(20).generate_network(:euclidean, :radius=>1.2 )
        assert graph.mean_degree>9
        graph = JGGraph.new(20).generate_network(:euclidean, :radius=>1.3 )
        assert graph.mean_degree>9
        graph = JGGraph.new(20).generate_network(:euclidean, :radius=>1.4 )
        assert graph.mean_degree>9
      end
    end

    it "should be sparse with radius of 0 to 0.5" do

      (0..10).each do
        graph = JGGraph.new(20).generate_network(:euclidean, :radius=>0)
        assert graph.mean_degree<9
      end
    end
  end

  describe "when generated small world network" do
    it "should have mean degree close to the one given in parameters" do
      (0..10).each do
        graph = JGGraph.new(200).generate_network(:small_world, :mean_degree=>10, :rewiring_probability => 0.01)
        assert graph.mean_degree-10<0.5
      end
    end

    it "generates graph where clustering coefficient is much bigger than of random network generated on same node set" do
      graph_small_world = JGGraph.new(100).generate_network :small_world, :mean_degree=>10, :rewiring_probability => 0.01
      graph_small_world.clean_up
      graph_random = JGGraph.new(100).generate_network :random, :edge_probability => 0.01
      graph_small_world.clean_up
      assert graph_small_world.clustering_coefficient > 10000*graph_random.clustering_coefficient
    end
  end

  describe "when generated scale-free network" do
    it "should have" do
      #todo
    end
  end
end
