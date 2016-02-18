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

# TODO - Hacer algo cuando llegan secuencias vacias

# class to execute Blast without temporary files (it uses pipes)

require 'tempfile'

class BatchBlast

  # class initialization
  def initialize(database, blast_type = 'blastn', extra_params = '')

    @blast_type = blast_type
    @database = database
    @extra_params = extra_params

  end

  # returns the blast cmd that will be used to launch blast
  def get_blast_cmd(fmt = :table, file=nil)

    if fmt==:table
      format = ' -outfmt "7 qseqid sacc pident length mismatch gapopen qstart qend sstart send evalue bitscore score qframe sframe qseq sseq qlen slen stitle" '
    elsif fmt ==:xml
      format = ' -outfmt 5 '
    end

    out=''

    if !file.nil? and !file.empty?
      out=" -out #{file}"
    else
      # if  RUBY_PLATFORM.index('darwin')
      #   out =" | sed -l"
      # else
      #   out =" | sed -l 0"
      # end
      # out =" | grep --line-buffered ''"
    end

    dust=''

    cmd = @blast_type+' '+dust+@extra_params + format + @database + out

    return cmd

  end

  # do a blast to seqs
  def do_blast(seqs, fmt = :table,parse_output=true,file=nil, use_pipe=false)

    if seqs.is_a?(Array)
      seq_fasta=seqs.join("\n")
    else
      seq_fasta=seqs
    end

    cmd = get_blast_cmd(fmt,file)
    #puts cmd
    #puts seqs
    if !seqs.empty?
      res = BatchBlast.do_blast_cmd(seq_fasta,cmd,use_pipe)
      if !file.nil? and !file.empty?
        res=file
      end
    else
      res=''
    end


    # check if all sequences where processed
    if parse_output
      if fmt == :table

        res = BlastTableResult.new(res)
      elsif fmt == :xml
        res = BlastStreamxmlResult.new(res)
        # elsif fmt ==:xml2
        # res = BlastXmlResult.new(res)
      end

      # puts "#{seq_fasta.count('>')}, #{res.querys.count}"

      if seq_fasta.count('>')!=res.querys.count
        not_processed = seqs.select{|e| e.index('>')}

        res.querys.each do |query|
          if not_processed.include?('>'+query.query_id)
            not_processed.delete('>'+query.query_id)
          end
        end

        raise "If using table format, please, use format 7. These queries where empty or not processed: #{seq_fasta.count('>')},#{res.querys.count}  by CMD: #{cmd}:\n #{not_processed} \n Full_data:\n seqs=#{seqs};\n"
      end

    end

    return res

  end

  def self.do_blast_cmd(seq_fasta, cmd, use_pipe = false)
    res=''
    if !seq_fasta.empty?
      # Ojo, que una vez nos ibamos a volver locos buscando porque esto no devolvia todos los hits que se  encontraban al ejecutar el blast a mano, y era porque en el blast a mano le estabamos pasando la secuencia completa mientras que en el MID le estabamos pasando solo los 20 primeros nt.

      # Change the buffering type in factor command,
      # assuming that factor uses stdio for stdout buffering.
      # If IO.pipe is used instead of PTY.open,
      # this code deadlocks because factor's stdout is fully buffered.

      # require 'pty'
      # require 'io/console' # for IO#raw!
      # res = []
      # m, s = PTY.open
      # s.raw! # disable newline conversion.
      # r, w = IO.pipe
      # pid = spawn(cmd, :in=>r, :out=>s)
      # r.close
      # s.close
      # w.puts seq_fasta
      # w.close
      # while !m.eof do
      #   res << m.gets
      # end

      if !use_pipe
        use_pipe= !ENV['SCBI_BLAST_USEPIPE'].nil?
      end


      # puts "="*60
      # puts res
      # puts "="*60
      if !use_pipe


        if !ENV['SCBI_BLAST_TMPDIR'].nil?
          file = Tempfile.new('scbi_blast_',ENV['SCBI_BLAST_TMPDIR'])
        else
          file = Tempfile.new('scbi_blast_')
        end

        begin
          file.puts seq_fasta
          file.close

          res=`#{cmd} -query #{file.path}`
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

      else # use pipes
        IO.popen(cmd,'w+') {|blast|
          blast.sync = true
          blast.write(seq_fasta)
          blast.close_write
          res = blast.readlines
          blast.close_read
        }

        if !$?.exitstatus.nil? && $?.exitstatus>0
          raise "Error doing blast #{cmd} to fasta: #{seq_fasta}"
        end
      end
    end

    return res

  end

  # do blast to an array of Sequence objects
  def do_blast_seqs(seqs, fmt = :table,parse_output=true, file=nil)

    # cmd = get_blast_cmd(fmt)

    fastas=[]

    seqs.each do |seq|
      fastas.push '>'+seq.seq_name
      fastas.push seq.seq_fasta
    end

    return do_blast(fastas,fmt,parse_output,file)

  end


  def close

  end

end
