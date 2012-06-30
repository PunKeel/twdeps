module TaskWarrior
  module Dependencies
    # 
    # +thing+ is added as node with all of its dependencies. 
    # +thing.to_s+ is called for the label.
    # +thing.id+ is called for the identifier. It must be unique within thing and all of its dependencies.
    #
    # +resolver.dependencies(thing)+ is called to resolve dependencies of +thing+. If must return a list
    # of things. Each thing may have its own dependencies which will be resolved recursively.
    #
    # Design influenced by https://github.com/glejeune/Ruby-Graphviz/blob/852ee119e4e9850f682f0a0089285c36ee16280f/bin/gem2gv
    #
    class Scanner
      def initialize(thing = nil, resolver)
        @graph = GraphViz::new(:G)
        @dependencies = []
        @resolver = resolver
        resolve(thing)
      end
      
      # TODO should be passed an IO object to write to
      def render(format = 'dot')
        @graph.output(format => nil)
      end
    
    private
      def resolve(thing = nil)
        if thing.nil?
          @resolver.dependencies.each{|t| resolve(t)}
        else        
          dependencies = @resolver.dependencies(thing)
          create_edges(thing, dependencies)
        
          # resolve all dependencies we don't know yet
          dependencies.each do |dependency|
            unless @dependencies.include?(dependency)
              @dependencies << dependency
              resolve(dependency)
            end
          end
        end
      end
  
      def create_edges(thing, nodes)
        nodeA = find_or_create_node(thing)
    
        nodes.each do |node|
          nodeB = find_or_create_node(node)
          @graph.add_edges(nodeA, nodeB)
        end
      end
      
      def find_or_create_node(thing)
        return @graph.get_node(thing.id) || @graph.add_nodes(thing.id, :label => thing.to_s)
      end
    end
  end
end