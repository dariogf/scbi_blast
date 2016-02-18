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

require 'nokogiri'

# Another XML parser using nokogiri library
class BlastXmlResult

  def initialize(input)

    @querys = []
    lines=[]

    if input.is_a?(Array)
      lines=input
    else
      if File.exists?(input)
        fich = File.open(input,'r')
        lines = fich.readlines
        fich.close
      end

    end

    # puts "lines length #{lines.length}"
    if !lines.empty?
      data = Nokogiri::XML(lines.join)
      data.root.xpath('//Iteration').each do |iteration|

        # puts JSON::pretty_generate(iteration)
        query_id = iteration.xpath('Iteration_query-ID').text

        full_query_length = iteration.xpath('Iteration_query-len').text
        query_def = iteration.xpath('Iteration_query-def').text

        if query_def =~ /^([^\s]+)/
          query_def=$1
        end

        #@query_def = iteration['Iteration_query-def'][0]

        query = BlastQuery.new(query_id)
        query.query_def = query_def
        query.full_query_length = full_query_length
        @querys.push query


        hits = iteration.xpath('Iteration_hits/Hit')
        if !hits.nil?
          hits.each do |h|
            #puts JSON::pretty_generate(h)



            subject_id=h.xpath('Hit_id').text
            acc =h.xpath('Hit_accession').text
            full_subject_length = h.xpath('Hit_len').text.to_i
            hit_def=h.xpath('Hit_def').text
            if hit_def=='No definition line'
              hit_def =subject_id
            end

            hsps = h.xpath('Hit_hsps/Hsp')

            hsps.each do |hsp|

              q_beg=hsp.xpath('Hsp_query-from').text.to_i
              q_end=hsp.xpath('Hsp_query-to').text.to_i
              s_beg=hsp.xpath('Hsp_hit-from').text.to_i
              s_end=hsp.xpath('Hsp_hit-to').text.to_i

              # creates the hit
              hit = BlastHit.new(q_beg,q_end,s_beg,s_end)

              hit.align_len=hsp.xpath('Hsp_align-len').text.to_i
              hit.ident=(hsp.xpath('Hsp_identity').text.to_f/hit.align_len)*100
              hit.gaps=hsp.xpath('Hsp_gaps').text.to_i
              hit.mismatches=hsp.xpath('Hsp_midline').text.count(' ').to_i - hit.gaps
              hit.e_val=hsp.xpath('Hsp_evalue').text.to_f
              hit.e_val = (hit.e_val*1000).round/1000.0
              hit.bit_score=hsp.xpath('Hsp_bit-score').text.to_f
              hit.bit_score = (hit.bit_score*100).round/100.0

              hit.score = hsp.xpath('Hsp_score').text.to_f
              hit.q_frame = hsp.xpath('Hsp_query-frame').text.to_i
              hit.s_frame =hsp.xpath('Hsp_hit-frame').text.to_i

              hit.q_seq = hsp.xpath('Hsp_qseq').text
              hit.s_seq = hsp.xpath('Hsp_hseq').text


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



  def inspect

    res = "Blast results:\n"
    res+= '-'*20
    res+= "\nQuerys: #{@querys.count}\n"
    @querys.each{|q| res+=q.inspect+"\n"}
    return res
  end

  def find_query(querys,name_q)
    #  newq = querys.find{|q| ( q.find{|h| (h.subject_id)})}
    new_q=nil

    if !querys.empty?
      new_q=querys.find{|q| (q.query_id==name_q)}
    end

    return new_q
  end

  def empty?

    return @querys.empty?
  end

  def size
    @querys.size
  end

  attr_accessor :querys
end
