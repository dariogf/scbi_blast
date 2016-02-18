# scbi_blast

* http://www.scbi.uma.es/downloads

## DESCRIPTION:

scbi_blast is a ruby gem to handle blast+ executions using pipes when possible to read data without the need of temporary files, 
it has been developed at [SCBI](http://www.scbi.uma.es) by Almudena Bocinos & Dario Guerrero.

## FEATURES:

* Execute blast (using pipe to read output). Pipes cannot be used for input since it will block if writing more 64kb.
* Parse XML and table results into Query and Hit objects
* Execute DustMasker without temporary files (using pipes for both input and output)

## SYNOPSIS:

scbi_blast can handle *blastn*, *blastp* and *dustmasker* applications from NCBI blast package. 
Input sequences can be supplied as an array (see the example below) or as a chunk of text 
inside a string variable.

There are two output formats supported (_table_ and _xml_) by the built-in parsers.

scbi_blast returns an object with all data parsed and splitted into querys and their respective hits. 

### Blast

Here is an example that shows how to use it to do a blastn:

  require 'scbi_blast'

  # create a blast processor object pointing to a formatted blast database 
  # that uses a blastn with 4 parallel threads

  blast=BatchBlast.new('-db formatted_blast_db.fasta','blastn','--num_threads 4')

  # fill in some sample sequences (in your code those sequences will come
  # from a file, an output of another process, etc...)

  seqs=[]
  seqs << ">GFIXVR"
  seqs << "GACTACACGACGACCCGACGACGACGAGAGNGNGGACCCGACGACG"
  seqs << ">GFIM12"
  seqs << "GACTACACGACGACTAGACCCGACGACGTGACCCGACGACG"


  # execute blast
  res=blast.do_blast(seqs)


  # iterate over results printing hit id, start and end positions.

  res.querys.each do |query|
    query.hits.each do |hit|
      puts hit.subject_id, hit.q_beg, hit.q_end
    end
  end
  

### DustMasker

An example that shows how to use it to find dust into some sequences:

  require 'scbi_blast'

  # create DustMasker object
  dust_masker=DustMasker.new()

  seqs=[]
  seqs << ">GFIXVR"
  seqs << "GACTACACGACGACCCGACGACGACGAGAGNGNGGACCCGACGACG"
  seqs << ">GFIM12"
  seqs << "GACTACACGACGACTAGACCCGACGACGTGACCCGACGACG"

  dust_regions = dust_masker.do_dust(seqs.join("\n"))

  puts "Found #{dust_regions.count} dust regions"

  dust_regions.each do |dust|
    # region is defined as an array, where element [0] is the start
    # of the region, and [1] is the end
    puts dust.join(',')
  end

## REQUIREMENTS:

* NCBI blast+ already installed

## ENVIRONMENT

You can set the SCBI_BLAST_TMPDIR environment variable to choose where input temfiles should be written.

## INSTALL:

gem install scbi_blast


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/scbi_blast.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

