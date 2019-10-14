# frozen_string_literal: true

module ODFReport

  module Images

    IMAGE_DIR_NAME = 'Pictures'

    def find_image_name_matches(content)

      @images.each_pair do |image_name, path|
        if node = content.xpath("//draw:frame[@draw:name='#{image_name}']/draw:image").first
          width, height = FastImage.size(path)
          new_height_value = node.parent.attribute('width').value.to_f * height / width
          node.parent.attribute('height').value = "#{new_height_value}cm"

          new_name = SecureRandom.hex(20).upcase
          new_value = "#{IMAGE_DIR_NAME}/#{::File.basename(node.attribute('href').value).gsub(/\A\w{40}/, new_name)}"
          node.attribute('href').value = new_value

          @image_names_additions << {
            template_image: ::File.join(IMAGE_DIR_NAME, ::File.basename(new_value)),
            path: path
          }
        end
      end

    end

    def include_image_files(file)

      return if @images.empty?

      @image_names_additions.each do |image|

        file.output_stream.put_next_entry(image[:template_image])
        file.output_stream.write ::File.read(image[:path])

      end

    end # replace_images

    # newer versions of LibreOffice can't open files with duplicates image names
    def avoid_duplicate_image_names(content)

      nodes = content.xpath("//draw:frame[@draw:name]")

      nodes.each_with_index do |node, i|
        node.attribute('name').value = "pic_#{i}"
      end

    end

  end

end
