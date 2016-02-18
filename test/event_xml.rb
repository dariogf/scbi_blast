# SAMPLE CODE FOR COMPARING THE PERFORMANCE OF DOM PARSING AND STREAM PARSING IN REXML
# uses people.xml as the source document;
# stream parsing is about 7 times faster, even on this small document

require 'rexml/document'
require 'rexml/streamlistener'
include REXML
include REXML::StreamListener

### classes to represent the objects and relationships in people.xml
class Person
  attr_accessor :id, :role, :first_name, :last_name, :addresses
  def initialize
    @addresses = []
  end
end

class Address
  attr_accessor :type, :public, :street, :city
end

# stream-based parsing
# the code is harder to follow and more verbose, but it
# performs far better
class StreamPeopleParser 

  def initialize(filename)
    @raw_xml = File.open(filename).read
    @people = []
    
    # some variables for tracking the state of the parse
    @current_address = nil
    @current_person = nil
    @current_element = nil
    do_parse
  end

  def do_parse
    Document.parse_stream(@raw_xml, self)
    @people
  end

  def tag_start(name, attributes)
    puts "+#{name}: #{attributes}"
    # case name
    #   when 'person'
    #     @current_person = Person.new
    #     @current_person.id = attributes['id']
    #     @current_person.role = attributes['role']
    #   when 'address'
    #     @current_address = Address.new
    #     @current_address.type = attributes['type']
    #     @current_address.public = attributes['public']
    #   else
    #     @current_element = name
    # end
  end

  def tag_end(name)
    puts "-#{name}"
    # case name
    #   when 'person'
    #     @people << @current_person
    #   when 'address'
    #     @current_person.addresses << @current_address
    # end
  end

  def text(text)
    # case @current_element
    #   when 'first-name'
    #     @current_person.first_name = text
    #   when 'last-name'
    #     @current_person.last_name = text
    #   when 'street'
    #     @current_address.street = text
    #   when 'city'
    #     @current_address.city = text
    # end
    # reset the current element so we don't pick up empty text
    @current_element = nil
  end
  
end



p=StreamPeopleParser.new('blast.xml')