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


require "scbi_blast/blast_query.rb"
require "scbi_blast/blast_hit.rb"


# Extracts results from blast table's file and uses it to create instances of "BlastQuery" and "BlastHit"
class BlastTableResult < BlastResult

  # Parser initialization
  def initialize(input)

    super(input)

    return if input.empty?
    
    if input.is_a?(Array)
      #lines=input
      parse(input)
    else
      fich = File.open(input,'r')
      #lines = fich.readlines
      parse(fich)
      fich.close
    end

    

  end

  def new_query(query_id,last_query)

    query=last_query

    if last_query.nil? || last_query.query_id != query_id
      query = BlastQuery.new(query_id)
      @querys.push query
    end

    return query

  end
  
  def parse(lines)
    
    clean_queries!

    with_comments=false

    #if lines.first.index('#')==0 
    #    with_comments=true
    #    if !(lines.last =~ /# BLAST processed (\d+) queries/)
    #        raise "Blast didn't processed your queries"
    #    end
    #end
    
    query_name=''
    last_query=nil
    line=''

    lines.each do |iline|

      #line.chomp! #delete end of line
      line=iline.chomp

      if line =~ /^\s*#/ # it is a comment line
        
        with_comments=true

        if line =~ /^#\sQuery:\s+(.+)$/
          query_name = $1
          last_query=new_query(query_name,last_query)
          
        #elsif line =~ /^#\s0\shits\sfound$/
        #  last_query=BlastQuery.new(query_name)

        #  @querys.push last_query
        end
        
        # 0 hits found

      else # no comment line
        params = line.split(/\t+/)

        # puts "Extracted #{params[0]} #{params[1]} #{params[2]} #{params[3]} #{params[4]} #{params[5]} #{params[6]} #{params[7]} #{params[8]} #{params[9]} #{params[10]} #{params[11]}"
        #         Options 6, 7, and 10 can be additionally configured to produce
        #   a custom format specified by space delimited format specifiers.
        #   The supported format specifiers are:
        #            qseqid means Query Seq-id
        #               qgi means Query GI
        #              qacc means Query accesion
        #            sseqid means Subject Seq-id
        #         sallseqid means All subject Seq-id(s), separated by a ';'
        #               sgi means Subject GI
        #            sallgi means All subject GIs
        #              sacc means Subject accession
        #           sallacc means All subject accessions
        #            qstart means Start of alignment in query
        #              qend means End of alignment in query
        #            sstart means Start of alignment in subject
        #              send means End of alignment in subject
        #              qseq means Aligned part of query sequence
        #              sseq means Aligned part of subject sequence
        #            evalue means Expect value
        #          bitscore means Bit score
        #             score means Raw score
        #            length means Alignment length
        #                        pident means Percentage of identical matches
        #            nident means Number of identical matches
        #          mismatch means Number of mismatches
        #          positive means Number of positive-scoring matches
        #           gapopen means Number of gap openings
        #              gaps means Total number of gaps
        #              ppos means Percentage of positive-scoring matches
        #            frames means Query and subject frames separated by a '/'
        #            qframe means Query frame
        #            sframe means Subject frame
        #   When not provided, the default value is:
        #   'qseqid sseqid pident length mismatch gapopen qstart qend sstart send
        #   evalue bitscore', which is equivalent to the keyword 'std'

        # if  the query doesn't exist, then create a new one,
        # else the hit will be added to the last query

        qseqid,sacc,pident,length,mismatch,gapopen,qstart,qend,sstart,send,evalue,bitscore,score,qframe,sframe,qseq,sseq,qlen,slen,stitle = params
        
        # if format6 
        #if !with_comments and query_name!=qseqid
        #    @querys.push BlastQuery.new(query_name)
        #    query_name=qseqid
        #end

        # creates the hit
        hit = BlastHit.new(qstart,qend,sstart,send)

        hit.align_len=length
        hit.ident=pident

        hit.gaps=gapopen
        hit.mismatches=mismatch
        hit.e_val=evalue
        hit.bit_score=bitscore

        hit.score = score
        hit.q_frame = qframe
        hit.s_frame = sframe

        hit.subject_id = sacc
        hit.full_subject_length=slen # era 0
        hit.definition=stitle # era sacc
        hit.acc=sacc
        hit.q_seq=qseq
        hit.s_seq=sseq
        hit.q_len=qlen
        hit.s_len=slen
        

        #query=find_query(@querys,qseqid)
        last_query=new_query(qseqid,last_query)
        last_query.add_hit(hit)
        last_query.full_query_length=qlen

        #Description

        # read_blast_tab read tabular BLAST format created with blast_seq and written to file with write_blast - or with blastall and the -m 8 or -m 9 switch.
        #           Each column in the table corresponds to the following keys:
        #
        #              1. Q_ID - Query ID.
        #              2. S_ID - Subject ID.
        #              3. IDENT - Identity (%).
        #              4. ALIGN_LEN - Alignment length.
        #              5. MISMATCHES - Number of mismatches.
        #              6. GAPS - Number of gaps.
        #              7. Q_BEG - Query begin.
        #              8. Q_END - Query end.
        #              9. S_BEG - Subject begin.
        #             10. S_END - Subject end.
        #             11. E_VAL - Expect value.
        #             12. BIT_SCORE - Bit score.
        #
        #           Furthermore, two extra keys are added to the record:
        #
        #               * STRAND - Strand.
        #               * REC_TYPE - Record type.
      end

    end

    if with_comments
        if !( line =~ /# BLAST processed (\d+) queries/)
            raise "Blast didn't processed your queries"
        end
    
    end


    #inspect

  end

end
