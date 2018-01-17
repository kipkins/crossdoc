require_relative './util'

module CrossDoc

  class Styler

    DEFAULT_STYLE = {
        FOOTER_LEFT: {
            font: {
                size: 10
            }
        },
        FOOTER_CENTER: {
            font: {
                size: 10,
                align: 'center'
            }
        },
        FOOTER_RIGHT: {
            font: {
                size: 10,
                align: 'right'
            }
        },
        H1: {
            font: {
                size: 24
            },
            margin: {bottom: 6}
        },
        H2: {
            font: {
                size: 20
            },
            margin: {bottom: 6}
        },
        H3: {
            font: {
                size: 18
            },
            margin: {bottom: 6}
        },
        P: {
            font: {
                size: 12
            },
            margin: {bottom: 12}
        },
        UL: {
            margin: {bottom: 12, left: 20}
        },
        OL: {
            margin: {bottom: 12, left: 20}
        },
        LI: {
            font: {
                size: 12,
                line_height: 24
            }
        }
    }

    def initialize(styles)
      @styles = DEFAULT_STYLE.deep_merge styles.sanitize_keys
    end


    def style_node(node, tag=nil)
      tag = (tag ||node.tag).to_s.upcase.to_sym
      node_style = @styles[tag] || {}

      node.default_font node_style[:font] || {}

      unless node_style.has_key? :margin_cache
        raw_margin = {top: 0, right: 0, bottom: 0, left: 0}.merge (node_style[:margin] || {})
        node_style[:margin_cache] = Margin.new raw_margin
      end
      node.margin = node_style[:margin_cache]

      unless node_style.has_key? :padding_cache
        raw_padding = {top: 0, right: 0, bottom: 0, left: 0}.merge (node_style[:padding] || {})
        node_style[:padding_cache] = Margin.new raw_padding
      end
      node.padding = node_style[:padding_cache]
    end

  end

end