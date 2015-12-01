module CrossDoc

  # DSL for recursively creating nodes
  class NodeBuilder
    include CrossDoc::RawShadow

    raw_shadow :padding, -> {Margin.new}

    raw_shadow :box, -> {Box.new}

    raw_shadow :border

    raw_shadow :background

    raw_shadow :text

    raw_shadow :font

    attr_accessor :block_orientation, :weight, :min_height, :margin

    def initialize(doc_builder, raw)
      @doc_builder = doc_builder

      @block_orientation = raw[:block_orientation] ? raw[:block_orientation].to_sym : :vertical
      raw.delete :block_orientation

      @weight = raw[:weight] || 1.0
      raw.delete :weight

      init_raw raw

      if @raw.has_key? :src
        self.image_src @raw[:src]
        @raw.delete :src
      end

      @child_builders = []

      @min_height = 0

      # we don't store the margin in @raw because it's not actually part of the CrossDoc schema
      @margin = Margin.new
    end

    def push_min_height(h)
      if h > @min_height
        @min_height = h
      end
    end

    def default_font(adjustments)
      self.font = CrossDoc::Font.default adjustments
    end

    def border_all(s)
      side = CrossDoc::BorderSide.from_s s
      self.border = CrossDoc::Border.new top: side, right: side, left: side, bottom: side
    end

    def border_top(s)
      side = CrossDoc::BorderSide.from_s s
      self.border = CrossDoc::Border.new unless self.border
      self.border.top = side
    end

    def border_bottom(s)
      side = CrossDoc::BorderSide.from_s s
      self.border = CrossDoc::Border.new unless self.border
      self.border.bottom = side
    end

    def border_left(s)
      side = CrossDoc::BorderSide.from_s s
      self.border = CrossDoc::Border.new unless self.border
      self.border.left = side
    end

    def border_right(s)
      side = CrossDoc::BorderSide.from_s s
      self.border = CrossDoc::Border.new unless self.border
      self.border.right = side
    end

    def background_color(c)
      unless self.background
        self.background = CrossDoc::Background.new
      end
      self.background.color = c
    end

    def image_src(src)
      @raw[:src] = src
      hash = src.hash.to_s
      @raw[:hash] = hash
      @doc_builder.add_image src, hash
    end

    def node(tag, raw={})
      raw[:tag] = tag.upcase
      node_builder = NodeBuilder.new @doc_builder, raw
      yield node_builder
      @child_builders << node_builder
    end

    def horizontal_div(raw={})
      raw[:tag] = 'DIV'
      raw[:block_orientation] = 'horizontal'
      node_builder = NodeBuilder.new @doc_builder, raw
      yield node_builder
      @child_builders << node_builder
    end

    def div(raw={})
      raw[:tag] = 'DIV'
      raw[:block_orientation] = 'vertical'
      node_builder = NodeBuilder.new @doc_builder, raw
      yield node_builder
      @child_builders << node_builder
    end

    def child_width
      self.box.width - self.padding.left - self.padding.right
    end

    # sets the position and size of the node based on the starting position and width (including margin)
    # returns the height consumed
    def flow(x, y, w)
      self.box.x = x + @margin.left
      self.box.y = y + @margin.top
      self.box.width = w - @margin.left - @margin.right

      # layout the children
      if @block_orientation == :horizontal
        flow_children_horizontal
      else # vertical
        flow_children_vertical
      end

      # compute/update the height
      if self.text && self.font
        # stupid simple font metrics
        num_lines = (self.text.length * self.font.size * 0.48 / child_width).ceil
        push_min_height (self.font.line_height || 1) * num_lines
      end
      self.box.height = @min_height + self.padding.top + self.padding.bottom

      self.box.height + @margin.top + @margin.bottom
    end

    def to_node
      @raw[:children] = @child_builders.map { |b| b.to_node }
      CrossDoc::Node.new @raw
    end

    private

    def total_child_weight
      @child_builders.map { |b| b.weight }.sum
    end

    def flow_children_vertical
      width = child_width
      x = self.padding.left
      y_top = self.padding.top
      y = y_top
      @child_builders.each do |b|
        dy = b.flow x, y, width
        y += dy
      end
      if (y-y_top) > self.box.height
        push_min_height y-y_top
      end
    end

    def flow_children_horizontal
      total_weight = total_child_weight
      width = child_width
      x = self.padding.left
      y = self.padding.top
      @child_builders.each do |b|
        w = (b.weight/total_weight.to_f*width).round.to_i
        dy = b.flow x, y, w
        x += w
        push_min_height dy
      end
    end

  end


  # DSL for creating a page in a document
  class PageBuilder < NodeBuilder
    include CrossDoc::RawShadow

    raw_shadow :padding, -> {Margin.new}

    raw_shadow :box, -> {Box.new}

    def initialize(doc_builder, raw)
      super
      @raw = {orientation: 'portrait', size: 'us-letter', page_margin: '0.75in'}.merge @raw
      dimensions = Page.get_dimensions @raw
      self.box.width = dimensions[:width]
      self.box.height = dimensions[:height]

      margin_size = Page.page_margin_size @raw[:page_margin]
      self.padding.set_all margin_size
    end

    def to_page
      flow_children_vertical
      @raw[:children] = @child_builders.map { |b| b.to_node }
      CrossDoc::Page.new @raw
    end

  end


  # Creates a document through a ruby DSL
  class Builder

    def initialize
      @page_builders = []
      @images = {}
    end

    def page(raw)
      page_builder = PageBuilder.new self, raw
      yield page_builder
      @page_builders << page_builder
    end

    def add_image(src, hash)
      @images[hash] = CrossDoc::ImageRef.new src: src, hash: hash
    end

    def to_doc
      pages = @page_builders.map {|pb| pb.to_page}
      CrossDoc::Document.new pages: pages, images: @images
    end

  end

end