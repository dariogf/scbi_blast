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

require 'zlib'
require 'xmlsimple'

# Extracts results from a blast results in XML
# format and uses it to create instances of "BlastQuery" and "BlastHit"
class BlastSimplexmlResult < BlastResult

  # Parser initialization
  def initialize(input)
    super(input)

    lines=[]
    if input.is_a?(Array)
      lines=input
    elsif !input.strip.empty?
      if File.exists?(input)
        fich = File.open(input,'r')
        lines = fich.readlines
        fich.close
      else
        raise "File #{input} doesn't exists"
      end
    end
    parse(lines)
  end
  
  def parse(lines)

    # puts "lines length #{lines.length}"
    if !lines.empty?
      data = XmlSimple.xml_in(lines.join)
      iterations = data['BlastOutput_iterations']
      #require 'json'
      #puts iterations.to_json

      iterations[0]['Iteration'].each do |iteration|

        # puts JSON::pretty_generate(iteration)

        query_id = iteration['Iteration_query-ID'][0]
        full_query_length = iteration['Iteration_query-len'][0].to_i
        query_def = iteration['Iteration_query-def'][0]

        if query_def =~ /^([^\s]+)/
          query_def=$1
        end
        

        #@query_def = iteration['Iteration_query-def'][0]

        query = BlastQuery.new(query_id)
        query.query_def = query_def
        query.full_query_length = full_query_length
        @querys.push query



        hits = iteration['Iteration_hits'][0]['Hit']
        if !hits.nil?
          hits.each do |h|
            #puts JSON::pretty_generate(h)



            subject_id=h['Hit_id'][0]
            acc =h['Hit_accession'][0]
            full_subject_length = h['Hit_len'][0].to_i
            hit_def=h['Hit_def'][0]
            if hit_def=='No definition line'
              hit_def =subject_id
            end

            hsps = h['Hit_hsps'][0]['Hsp']

            hsps.each do |hsp|

              q_beg=hsp['Hsp_query-from'][0].to_i
              q_end=hsp['Hsp_query-to'][0].to_i
              s_beg=hsp['Hsp_hit-from'][0].to_i
              s_end=hsp['Hsp_hit-to'][0].to_i

              # creates the hit
              hit = BlastHit.new(q_beg,q_end,s_beg,s_end)

              hit.align_len=hsp['Hsp_align-len'][0].to_i
              hit.ident=(hsp['Hsp_identity'][0].to_f/hit.align_len)*100
              hit.gaps=hsp['Hsp_gaps'][0].to_i
              hit.mismatches=hsp['Hsp_midline'][0].count(' ').to_i - hit.gaps
              hit.e_val=hsp['Hsp_evalue'][0].to_f
              hit.e_val = (hit.e_val*1000).round/1000.0
              hit.bit_score=hsp['Hsp_bit-score'][0].to_f
              hit.bit_score = (hit.bit_score*100).round/100.0

              hit.score = hsp['Hsp_score'][0].to_f
              hit.q_frame = hsp['Hsp_query-frame'][0].to_i
              hit.s_frame =hsp['Hsp_hit-frame'][0].to_i

              hit.q_seq = hsp['Hsp_qseq'][0]
              hit.s_seq = hsp['Hsp_hseq'][0]


              hit.subject_id= subject_id
              hit.full_subject_length=full_subject_length
              # hit.full_query_length = full_query_length
              hit.definition=hit_def
              hit.acc=acc

              query.add_hit(hit)

            end
          end
        end
      end
    end
    #inspect
  end

end
