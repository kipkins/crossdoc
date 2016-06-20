# CrossDoc Ruby Library

CrossDoc is a platform-independent document interchange format.

This is the Ruby server library and JavaScript client library for CrossDoc.
It is the defacto standard implementation of CrossDoc PDF rendering.

## Installation

Add this line to your application's Gemfile:

    gem 'crossdoc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crossdoc

## Usage


### Documents in HTML

Each CrossDoc document begins its life as an HTML view rendered in a browser.
This HTML structure uses a few conventions to tell CrossDoc how to serialize it.

A basic document is structured like this:

```html
<div class="crossdoc" id="document">
    <div class="page us-letter decorated margin-75" id="page1">
        <!-- Page Content -->
    </div>
    <div class="page us-letter decorated margin-75" id="page2">
        <!-- Page Content -->
    </div>
</div>
```

There is one containing div with class *crossdoc*.
Each page is it's own div with class *page*, and optional classes for formatting:

* Page size: *us-letter* (default) or *us-legal*
* Page margin: *margin-50*, *margin-75*, or *margin-100* for 1/2", 3/4", or 1" margins, respectively
* Decoration: *decorated* applies a simple white background, border, and drop shadow to the page

Inside each page, you place the markup for your document.
The actual markup can be basically anything you want.
The CrossDoc JavaScript library (see next section) will serialize the document structure and layout into a platform-neutral JSON format, which can then be sent to a server to render into a PDF.


### JavaScript API

Serializing a document to JSON is done with the CrossDoc JavaScript API:

```javascript
var doc = window.crossdoc.create(); // create the document container
doc.parse('document'); // parse the document, passed by id
var json = doc.toJSON(); // serialize the document to JSON
```

Once serialized, you can send the document to your server through an AJAX call or form parameter.


### Ruby API

On the server, the Ruby API lets you take a JSON document representation and render it to a PDF.

```ruby
doc = CrossDoc::Document.new JSON.parse(doc_json) # create a document from a JSON string
renderer = CrossDoc::PdfRenderer.new doc # create a PDF renderer to render the document
renderer.to_pdf 'path/to/output.pdf' # render the document to a PDF in the filesystem
```

The renderer will download all images included in the document and render the contents to a PDF using the [Prawn](http://http://prawnpdf.org/) PDF library.


### Ruby Builder

In addition to serializing DOM elements to the intermediate JSON representation, 
CrossDoc also has a builder API that lets you create the document from a Ruby DSL.
The builder API allows CrossDoc documents to be generated without a browser.

```ruby
# create a builder and configure the page properties
builder = CrossDoc::Builder.new page_size: 'us-letter', page_orientation: 'portrait', page_margin: '0.5in'

# create a new page
builder.page do |page|
    # create a container for layout, can be horizontal or vertical
    page.horizontal_div do |layout|
        # each child can have a layout weight
        layout.node 'p', {weight: 2} do |p|
            p.default_font size: 12, color: '#800' # creates a new font by replacing default font values
            p.padding.top = 8 # set just one side of padding
            p.text = "This paragraph is larger"
        end
        layout.node 'p' do |p|
            p.border_left '0.5px solid #080' # CSS borer definitions
            p.padding.set_all 4 # set all padding at once
            p.text = "This paragraph is half as wide"
        end
    end
end

# create the raw document that can be passed to a renderer
doc = builder.to_doc
CrossDoc::PdfRenderer.new(doc).to_pdf 'path/to/output.pdf'
```


### Rails Integration

To use CrossDoc in a Rails application, simply include the gem in your Gemfile and add the stylesheet and javascript file to your assets:

```css
/* application.css or similar
*= require crossdoc
*/
```

```javascript
// application.js or similar
//= require crossdoc
```



## Contributing

1. Fork it ( http://github.com/TinyMission/crossdoc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
