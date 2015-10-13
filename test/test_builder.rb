require 'minitest/autorun'
require 'crossdoc'


class TestBuilder < Minitest::Test
  def setup
  end

  def test_builder
    doc = build_demo_doc

    File.open('test/output/builder.json', 'wt') do |f|
      f.write JSON.pretty_generate(doc.to_raw)
    end

    renderer = CrossDoc::PdfRenderer.new doc
    renderer.show_overlays = true
    renderer.to_pdf 'test/output/builder.pdf'
  end

  def build_demo_doc
    builder = CrossDoc::Builder.new

    header_color = '#008888ff'
    body_color = '#222222ff'

    builder.page size: 'us-letter', orientation: 'portrait', page_margin: '0.5in' do |page|
      page.node 'div', {block_orientation: :horizontal} do |header|
        header.node 'div', {block_orientation: :horizontal} do |left_header|
          left_header.node 'img', {src: 'https://placeholdit.imgix.net/~text?txtsize=60&txt=Photo&w=400&h=300&fm=png'} do |logo|
            logo.push_min_height 100
            logo.margin.set_all 8
          end
          left_header.node 'div', {} do |company_info|
            info_font = CrossDoc::Font.default size: 8, color: body_color
            company_info.node 'div', {} do |name_row|
              name_row.font = info_font
              name_row.padding.set_all 4
              name_row.text = 'ACME LLC'
            end
            company_info.node 'div', {} do |phone_row|
              phone_row.font = info_font
              phone_row.padding.set_all 4
              phone_row.text = '952-555-1234'
            end
          end
        end
        header.node 'div', {} do |right_header|
          right_header.node 'h1', {} do |n|
            n.default_font size: 32, align: :right, color: header_color
            n.text = 'Hello World'
          end
          right_header.node 'h2', {} do |n|
            n.default_font size: 24, align: :right, color: header_color
            n.text = 'Subheader'
          end
        end
      end

      page.node 'div', {block_orientation: :horizontal} do |content|
        content.margin.top = 20
        content.node 'div', {weight: 2} do |left_content|
          left_content.node 'p', {} do |p1|
            p1.default_font size: 12, color: body_color
            p1.padding.set_all 8
            p1.text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
          end
          left_content.node 'p', {} do |p2|
            p2.default_font size: 12, color: body_color
            p2.padding.set_all 8
            p2.text = 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?'
          end
        end
        content.node 'div', {weight: 1} do |right_content|
          right_content.node 'div', {} do |bordered_content|
            bordered_content.border_all '1px solid #aaaaaaff'
            bordered_content.padding.set_all 8
            bordered_content.margin.set_all 8
            bordered_content.default_font size: 14, color: body_color
            bordered_content.text = 'This content should have a border around it'
          end
        end
      end
    end

    builder.to_doc
  end

end