require 'json'

# The module for JSON related functionality.
module PuppetStrings::Json
  # Renders the current YARD registry as JSON to the given file (or STDOUT if nil).
  # @param [String] file The path to the output file to render the registry to. If nil, output will be to STDOUT.
  # @return [void]
  def self.render(file = nil)
    document = {
      puppet_classes: YARD::Registry.all(:puppet_class).sort_by!(&:name).map!(&:to_hash),
      defined_types: YARD::Registry.all(:puppet_defined_type).sort_by!(&:name).map!(&:to_hash),
      resource_types: YARD::Registry.all(:puppet_type).sort_by!(&:name).map!(&:to_hash),
      providers: YARD::Registry.all(:puppet_provider).sort_by!(&:name).map!(&:to_hash),
      puppet_functions: YARD::Registry.all(:puppet_function).sort_by!(&:name).map!(&:to_hash),
      # TODO: Need Ruby documentation?
    }

    if file
      File.open(file, 'w') do |f|
        f.write(JSON.pretty_generate(document))
        f.write("\n")
      end
    else
      puts JSON.pretty_generate(document)
    end
  end

  # TODO: document
  # @return [Array] array of tag hashes
  def self.tags_to_hashes(tags)
    tags.map do |t|
      next t.to_hash if t.respond_to?(:to_hash)

      tag = { tag_name: t.tag_name }
      tag[:text] = t.text if t.text
      tag[:types] = t.types if t.types
      tag[:name] = t.name if t.name
      tag
    end
  end

  # Converts a YARD::Docstring (or String) to a docstring hash for JSON output.
  # @param [YARD::Docstring, String] docstring The docstring to convert to a hash.
  # @return [Hash] Returns a hash representation of the given docstring.
  def self.docstring_to_hash(docstring)
    hash = {}
    hash[:text] = docstring
    if docstring.is_a? YARD::Docstring
      # Skip over the API tags that are public
      tags = tags_to_hashes(docstring.tags.select { |t| (t.tag_name != 'api' || t.text != 'public') &&
                                                        (t.tag_name != 'param' && t.tag_name != 'return')})
      hash[:tags] = tags unless tags.empty?
    end
    hash
  end

  def self.signature_docstring_to_hash(docstring)
    hash = {}
    hash[:text] = docstring
    if docstring.is_a? YARD::Docstring
      # Skip over the API tags that are public
      tags = tags_to_hashes(docstring.tags.select { |t| (t.tag_name != 'api' || t.text != 'public') &&
                                                        (t.tag_name == 'param' || t.tag_name == 'return')})

      #tags = tags.map { |t| t.reject {|k,v| k == :tag_name || k == :name } }
      hash[:tags] = tags unless tags.empty?
    end
    hash
  end
end
