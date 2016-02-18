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


# Object to encapsulate a Blast Query
class BlastQuery

  attr_accessor :hits
  attr_accessor :query_id, :query_def, :full_query_length

  # initializes a new Query object
  def initialize(query_id)
    @query_id = query_id
    @query_def = query_id
    @full_query_length = 0
    @hits = []
    # inspect
  end

  # add a hit to query
  def add_hit(h)
    @hits.push h
  end

  # inspect query values with all hits
  def inspect
    res = "\n * Query  #{@query_id}, #{@query_def}, #{@full_query_length} :"
    res += "subject_id ident align_len mismatches gaps q_beg q_end s_beg s_end e_val bit_score reversed\n\n"
    @hits.each{ |h| res+= "=="+h.inspect+"\n" }

    return res
  end

  # get num of hits
  def size
    return @hits.size
  end

  # sort hits by command
  def sort(comand)
    return @hits.sort(comand)
  end

  # merge overlapping hits
  def merged_hits!(overlap_threshold=0, merged_ids=nil)
    res = []

    merge_hits(@hits,res,merged_ids)

    begin
      res2=res # iterate until no more overlaps
      res = []
      merge_hits(res2,res,merged_ids)
    end until (res2.count == res.count)


    return res
  end
  
  def compare?(query)
    res=true
    

    # same hits
    res &&=( @hits.count==query.hits.count)
    
    # if !res 
    #    puts "Queries not equal:"
    #    puts inspect
    #    puts "="*20
    #    puts query.inspect
    #  end
    
    if res
      @hits.each_with_index do |h,i|
        res &&= h.compare?(query.hits[i])
      end
    end
    
    # if !res 
    #    puts "Queries hits not equal:"
    #    puts inspect
    #    puts "="*20
    #    puts query.inspect
    #  end
    
    res &&=( @query_id==query.query_id)
    res &&=( @query_def==query.query_def)
    res &&=( @full_query_length==query.full_query_length)
    
    
    return res
  end

private

  # do only one iteration of merge hits 
  def merge_hits(hits,merged_hits,merged_ids=nil)
    # puts " merging ============"
    hits.each do |hit|

      # save definitions
      merged_ids.push hit.definition if !merged_ids.nil? && (!merged_ids.include?(hit.definition))

      # find overlapping hits
      c=merged_hits.find{|c2| hit.query_overlaps?(c2)}

      if (c.nil?)
        # add new hit
        merged_hits.push(hit.dup)
      else

        # merge with old hit
        c.q_beg=[c.q_beg,hit.q_beg].min
        c.q_end=[c.q_end,hit.q_end].max

        c.subject_id += ' ' + hit.subject_id if (not c.subject_id.include?(hit.subject_id))

      end

    end
  end

end
