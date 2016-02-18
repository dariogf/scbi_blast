# Copyright (c) 2010 Dario Guerrero & Almudena Bocinos
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'tempfile'


# DustQuery class
class DustQuery

  attr_accessor :query_id,:dust

  def initialize(query_id)
    @dust=[]
    @query_id = query_id
  end

  def push(interval)
    @dust.push interval
  end

  def inspect
    res= "Query #{query_id}:"
    @dust.each do |d|
      res += " from #{d[0]} to #{d[1]}"
    end
  end

end

# DustMasker launcher class
class DustMasker

  # initializator
  def initialize(extra_params = '')

    @format = 'interval'
    @extra_params=extra_params

  end

  # returns command to be executed
  def get_cmd(extra_params = '')

    cmd = 'dustmasker '+@extra_params + '-outfmt '+ @format + ' 2>/dev/null'
    return cmd

  end

  # do the processing with dustmasker to a set of sequences in fasta stored in a string
  def do_dust(seq_fasta, use_pipe=false)
    intervals=[]

    if !seq_fasta.nil? && !seq_fasta.empty?

      if seq_fasta.is_a?(Array)
        seq_fasta=seq_fasta.join("\n")
      end

      cmd = get_cmd(@extra_params)
      if !seq_fasta.index('>')
        raise "Data passed to dust must be in fasta format"
      end


      if !use_pipe
        use_pipe= !ENV['SCBI_BLAST_USEPIPE'].nil?
      end

      if !use_pipe

        if !ENV['SCBI_BLAST_TMPDIR'].nil?
          file = Tempfile.new('scbi_blast_dust_',ENV['SCBI_BLAST_TMPDIR'])
        else
          file = Tempfile.new('scbi_blast_dust_')
        end
        begin
          file.puts seq_fasta
          file.close

          res=`#{cmd} -in #{file.path}`
          res=res.split("\n")

          if !$?.exitstatus.nil? && $?.exitstatus>0
            raise "Error doing blast #{cmd} to fasta: #{seq_fasta}"
          end

          # puts "FILEPATH"+file.path
        ensure
          file.close!   # Closes the file handle. If the file wasn't unlinked
          # because #unlink failed, then this method will attempt
          # to do so again.
          file.unlink   # On Windows this silently fails.
        end

      else

        # puts seq_fasta
        res=''

        # Ojo, que una vez nos ibamos a volver locos buscando porque esto no devolvia todos los hits que se  encontraban al ejecutar el blast a mano, y era porque en el blast a mano le estabamos pasando la secuencia completa mientras que en el MID le estabamos pasando solo los 20 primeros nt.
        IO.popen(cmd,'w+') {|blast|
          blast.sync = true
          # blast.write(">seq\n")
          blast.write(seq_fasta)
          blast.close_write
          res = blast.readlines
          blast.close_read
        }

        if !$?.exitstatus.nil? && $?.exitstatus>0
          raise "Error while doing #{cmd} to seq: #{seq_fasta}"
        end

      end

      res.each do |line|
        # puts "LINEA:" + line
        if line =~ /^>(.*)$/
          intervals.push DustQuery.new($1)
        elsif line =~ /^(\d+)\s\-\s(\d+)/
          # puts "Algo #{$1}, #{$2}"
          intervals.last.push [$1.to_i,$2.to_i]
        end

      end
    end

    return intervals

  end

  def close

  end

end
