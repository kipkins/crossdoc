require 'minitest/autorun'

# Base class for test runners, contains common operations like file I/O
class TestBase < Minitest::Test


  def write_doc(doc, name, options={})
    File.open("test/output/#{name}.json", 'wt') do |f|
      f.write JSON.pretty_generate(doc.to_raw)
    end

    if options[:paginate]
      CrossDoc::Paginator.new(num_levels: options[:paginate]).run doc
    end

    t = Time.now
    renderer = CrossDoc::PdfRenderer.new doc

    if options[:show_overlays]
      renderer.show_overlays = true
    end

    # renderer.add_horizontal_guide 3.5.inches
    # renderer.add_box_guide CrossDoc::Box.new(x: 0.875.inches, y: 2.5.inches, width: 3.inches, height: 1.125.inches)
    renderer.to_pdf "test/output/#{name}.pdf"
    dt = Time.now - t
    puts "Rendered #{name} PDF in #{dt} seconds"
  end

end
