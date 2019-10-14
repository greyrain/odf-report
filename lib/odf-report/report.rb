module ODFReport

class Report
  include Images

  def initialize(template_name = nil, io: nil)

    @template = ODFReport::Template.new(template_name, io: io)

    @texts = []
    @fields = []
    @tables = []
    @images = {}
    @image_names_additions = []
    @sections = []

    yield(self) if block_given?

  end

  def add_field(field_tag, value='')
    opts = {:name => field_tag, :value => value}
    field = Field.new(opts)
    @fields << field
  end

  def add_text(field_tag, value='')
    opts = {:name => field_tag, :value => value}
    text = Text.new(opts)
    @texts << text
  end

  def add_table(table_name, collection, opts={})
    opts.merge!(:name => table_name, :collection => collection)
    tab = Table.new(opts)
    @tables << tab

    yield(tab)
  end

  def add_section(section_name, collection, opts={})
    opts.merge!(:name => section_name, :collection => collection)
    sec = Section.new(opts)
    @sections << sec

    yield(sec)
  end

  def add_image(name, path)
    @images[name] = path
  end

  def generate(dest = nil)

    @template.update_content do |file|

      file.update_files do |doc|

        @sections.each { |s| s.replace!(doc) }
        @tables.each   { |t| t.replace!(doc) }

        @texts.each    { |t| t.replace!(doc) }
        @fields.each   { |f| f.replace!(doc) }

        find_image_name_matches(doc)
        avoid_duplicate_image_names(doc)

      end

      include_image_files(file)

      file.update_manifest do |manifest|
        @image_names_additions.each do |image|
          media_type = Marcel::MimeType.for(name: ::File.basename(image[:path]))
          full_path = image[:template_image]
          node_set = Nokogiri::XML::NodeSet.new(manifest)
          image = Nokogiri::XML::Node.new('file-entry', manifest)
          image.namespace = manifest.root.children.to_a[1].namespace

          image['full-path'] = full_path
          image.attributes['full-path'].namespace = manifest.root.children.to_a[1].namespace

          image['media-type'] = media_type
          image.attributes['media-type'].namespace = manifest.root.children.to_a[1].namespace

          node_set << image
          node_set << Nokogiri::XML::Text.new("\n ", manifest)
          manifest.root.first_element_child.before(node_set)
        end
      end

    end

    if dest
      ::File.open(dest, "wb") {|f| f.write(@template.data) }
    else
      @template.data
    end

  end

end

end
