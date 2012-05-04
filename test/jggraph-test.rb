require 'rspec/autorun'
require './jggraph.rb'

describe JGGraph do

  describe "when constructed" do
    before do
      @graph = JGGraph.new
    end

    it "should have no nodes" do
    	@graph.nodes.size.should == 0
    end

    it "should have no edges" do
    	@graph.edges.size.should == 0
    end
  end

  describe "when added some edges in tri edge cycle" do
    before do
      @graph = JGGraph.new
      @graph.add_nodes [0,1,2]
      @graph.add_edge 0, 1
      @graph.add_edge 1, 2
      @graph.add_edge 2, 0
    end

    it "should have edges" do
      @graph.edges.empty?.should == false
    end
  end

  describe "#add_nodes" do
    describe "with integer parameter" do
    it "should add given number of nodes when integer is passed" do
      graph = JGGraph.new
      graph.nodes.length.should==0
      graph.add_nodes(100)
      graph.nodes.length.should==100
      graph.add_nodes(100)
      graph.nodes.length.should==200
    end
    it "should add non nil nodes" do
      graph = JGGraph.new
      graph.add_nodes(100)
      graph.add_nodes(100)
      graph.nodes.each {|n| n.should_not ==nil}
    end
  end
    describe "with Array parameter" do
      it "should concatenate input array with nodes array" do
        graph = JGGraph.new
        graph.add_nodes [0,1,2,3]
        graph.nodes.should == [0,1,2,3]
        graph.add_nodes [4,5,6,7]
        graph.nodes.should == [0,1,2,3,4,5,6,7]
      end
    end
  end


  describe "generating networks when there are :node_count parameter" do
    def do_generate
      @graph.generate_network(:random, :node_count=>100, :edge_probability => 0.1)
    end
    it "should create the nodes" do
      @graph = JGGraph.new
      @graph.should_receive(:add_nodes).with(100)
      do_generate
    end
  end

  describe "when generated random network" do
    it "should have no edges if probability equals 0" do
      (0..10).each do JGGraph.new.generate_network(:random,:node_count=>20,  :edge_probability => 0).edges.empty?.should == true end
    end

    it "should be a full graph if probability equals 1" do
      (0..10).each do a = JGGraph.new.generate_network(:random,:node_count=>20, :edge_probability => 1).edges.size.should == 190 end
    end

    it "should have about N/2 edges if probability equals 0.5" do
      (0..10).each do JGGraph.new.generate_network(:random,:node_count=>20, :edge_probability => 0.5).edges.size.should <= 30+95 end
    end
  end

  describe "when generated euclidean network" do
    it "should be a full graph when radius is set to 1.5" do
      (0..10).each do JGGraph.new.generate_network(:euclidean,:node_count=>20, :radius=>1.5 ).edges.size.should == 190 end
    end

    it "should have no edges with radius of 0" do
      (0..10).each do JGGraph.new.generate_network(:euclidean,:node_count=>20, :radius=>0 ).edges.empty?.should ==true end
    end

    it "should be dense with radius of 0.8 to 1.5" do
      (0..10).each do
        graph = JGGraph.new.generate_network(:euclidean,:node_count=>20, :radius=>0.8 )
        graph.mean_degree.should > 9
        graph = JGGraph.new.generate_network(:euclidean,:node_count=>20, :radius=>0.9 )
        graph.mean_degree.should > 9
        graph = JGGraph.new.generate_network(:euclidean,:node_count=>20, :radius=>1.0 )
        graph.mean_degree.should > 9
        graph = JGGraph.new.generate_network(:euclidean,:node_count=>20, :radius=>1.1 )
        graph.mean_degree.should > 9
        graph = JGGraph.new.generate_network(:euclidean,:node_count=>20, :radius=>1.2 )
        graph.mean_degree.should > 9
        graph = JGGraph.new.generate_network(:euclidean,:node_count=>20, :radius=>1.3 )
        graph.mean_degree.should > 9
        graph = JGGraph.new.generate_network(:euclidean,:node_count=>20, :radius=>1.4 )
        graph.mean_degree.should > 9
      end
    end

    it "should be sparse with radius of 0 to 0.5" do

      (0..10).each do
        graph = JGGraph.new.generate_network(:euclidean,:node_count=>20, :radius=>0)
        graph.mean_degree.should < 9
      end
    end
  end

  describe "when generated small world network" do
    it "should have mean degree close to the one given in parameters" do
      (0..10).each do
        graph = JGGraph.new.generate_network(:small_world,:node_count=>200, :mean_degree=>10, :rewiring_probability => 0.01)
        (graph.mean_degree-10).should<0.5
      end
    end

    it "generates graph where clustering coefficient is much bigger than of random network generated on same node set" do
      graph_small_world = JGGraph.new.generate_network :small_world,:node_count=>100, :mean_degree=>10, :rewiring_probability => 0.01
      graph_small_world.clean_up
      graph_random = JGGraph.new.generate_network :random,:node_count=>100, :edge_probability => 0.01
      graph_small_world.clean_up
      graph_small_world.clustering_coefficient.should > graph_random.clustering_coefficient
    end
  end

  describe "when generated scale-free network" do
    it "it add nodes" do
      graph = JGGraph.new
      graph.generate_network :scale_free, :node_count=>100, :node_degree_increment_step => 0
      graph.nodes.length.should == 100
    end

    it "should create at least N edges" do
      graph = JGGraph.new
      graph.generate_network :scale_free, :node_count=>100, :node_degree_increment_step => 0
      graph.edges.length.should >= 99
    end
    it "should have no 0 degree edges" do
      graph = JGGraph.new
      graph.generate_network :scale_free, :node_count=>2, :node_degree_increment_step => 0
      graph.degree_distribution[0].should == nil
      graph = JGGraph.new
      graph.generate_network :scale_free, :node_count=>10, :node_degree_increment_step => 0
      graph.degree_distribution[0].should == nil
      graph = JGGraph.new
      graph.generate_network :scale_free, :node_count=>100, :node_degree_increment_step => 0
      graph.degree_distribution[0].should == nil
    end

  end

  describe "clustering coefficient" do
    it "should equal 1 in full graph" do
      g = JGGraph.new
      g.add_nodes [0,1,2]
      g.add_edge 0, 1
      g.add_edge 0, 2
      g.add_edge 1, 2
      g.clustering_coefficient.should == 1
    end
    it "should equal 1 for at triangle graph" do
      g = JGGraph.new
      g.add_nodes [0,1,2]
      g.add_edge 0, 1
      g.add_edge 0, 2
      g.add_edge 1, 2
      g.clustering_coefficient.should == 1.0
    end
    it "should equal 0 for two nodes connected with edge" do
      g = JGGraph.new
      g.add_nodes [0,1]
      g.add_edge 0,1
      g.clustering_coefficient.should == 0
    end

  end
end
