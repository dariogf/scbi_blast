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


# Class for a Blast Hit (a concordance between a query and a subject)
class BlastHit

  # initializes a new hit
  def initialize(q_beg,q_end,s_beg,s_end)
    set_limits(q_beg,q_end,s_beg,s_end)
  end
  
  def set_limits(q_beg,q_end,s_beg,s_end)
    # puts "Set limits #{[q_beg,q_end,s_beg,s_end].join(',')}"
    @q_beg = q_beg.to_i-1  #blast indexes are 1 based
    @q_end = q_end.to_i-1
    @s_beg = s_beg.to_i-1
    @s_end = s_end.to_i-1
    # puts "Set limits2 #{[@q_beg,@q_end,@s_beg,@s_end].join(',')}"
    
    @s_len=0
    @q_len=0

    @reversed = false

    # TODO -Reversed should be taken from q_frame and s_frame instead of s_end. In proteins comes from q_frame. In nt from s_frames.

    # check if reversed
    if @s_beg > @s_end
      @s_beg = s_end.to_i-1
      @s_end = s_beg.to_i-1
      @reversed = true
    end
    # puts "Set limits3 #{[@q_beg,@q_end,@s_beg,@s_end].join(',')}"
    # puts "Set limits4 #{[q_beg,q_end,s_beg,s_end].join(',')}"
    
  end

  # some accessors
  def subject_id=(v)
    @subject_id = v
  end

  def ident=(v)
    @ident = v.to_f
  end

  def align_len=(v)
    @align_len = v.to_i
  end

  def mismatches=(v)
    @mismatches = v.to_i
  end

  def gaps=(v)
    @gaps = v.to_i
  end

  def e_val=(v)
    @e_val = v.to_f
  end

  def bit_score=(v)
    @bit_score = v.to_f
  end

  def score=(v)

    @score = v.to_f
  end

  def acc=(v)
    @acc = v
  end

  def definition=(v)
    @definition = v
  end

  def q_frame=(v)
    @q_frame = v.to_i
  end

  def s_frame=(v)
    @s_frame = v.to_i
  end

  def s_seq=(v)
    @s_seq = v
  end

  def q_seq=(v)
    @q_seq = v
  end

  def s_len=(v)
    @s_len = v.to_i
  end

  def q_len=(v)
    @q_len = v.to_i
  end

  def full_subject_length=(v)
    @full_subject_length = v.to_i
  end

  # puts all hit info on a string
  def inspect
    res =  "Hit: #{@subject_id.ljust(10)} #{@ident.to_s.rjust(4)} #{@align_len.to_s.rjust(2)} #{@mismatches.to_s.rjust(2)} #{@gaps.to_s.rjust(2)} #{@q_beg.to_s.rjust(5)} #{@q_end.to_s.rjust(5)} #{@s_beg.to_s.rjust(5)} #{@s_end.to_s.rjust(5)} #{@e_val.to_s.rjust(5)}  #{@bit_score.to_s.rjust(5)} #{@reversed.to_s.rjust(5)}"
    res += " #{@score.to_s.rjust(5)} #{@acc.ljust(10)} #{@definition.ljust(10)} #{@q_frame.to_s.rjust(2)} #{@s_frame.to_s.rjust(2)} #{@full_subject_length.to_s.rjust(5)} #{@q_seq}.#{@s_seq}.#{@q_len}.#{@s_len}"

    return res
  end

  def get_subject
    return @subject_id
  end
  
  def query_overlaps?(hit,threshold=0)
    return ((@q_beg<=(hit.q_end+threshold)) and ((@q_end+threshold)>=hit.q_beg))
  end
  
  def size
    return (@q_end-@q_beg+1)
  end
  
  def compare?(hit)
    res=true
    
    res &&=( @q_beg==hit.q_beg)
    res &&=( @q_end==hit.q_end)
    res &&=( @s_beg==hit.s_beg)
    res &&=( @s_end==hit.s_end)
    
    res &&=( @subject_id==hit.subject_id)
    res &&=( @align_len==hit.align_len)
    res &&=( @gaps==hit.gaps)
    res &&=( @mismatches==hit.mismatches)
    
    
    res &&=( @reversed==hit.reversed)
    res &&=( @score==hit.score)
    res &&=( @acc==hit.acc)
    res &&=( @definition==hit.definition)
    
    
    res &&=( @q_frame==hit.q_frame)
    res &&=( @s_frame==hit.s_frame)
    res &&=( @full_subject_length==hit.full_subject_length)
    res &&=( @ident==hit.ident)
    
    
    res &&=( @e_val==hit.e_val)
    res &&=( @bit_score==hit.bit_score)
    res &&=( @q_seq==hit.q_seq)
    res &&=( @s_seq==hit.s_seq)
    
    if !res 
      puts "Hits not equal:"
      puts inspect
      puts "="*20
      puts hit.inspect
    end
    
    return res
  end

  # readers and accessor for properties
  attr_accessor :q_beg, :q_end, :s_beg, :s_end
  attr_reader :subject_id, :align_len, :gaps, :mismatches
  attr_accessor :reversed
  attr_reader :score, :acc, :definition, :q_frame, :s_frame, :full_subject_length, :ident, :e_val, :bit_score
  attr_reader :q_seq, :s_seq, :s_len, :q_len

end
