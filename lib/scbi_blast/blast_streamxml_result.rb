require "scbi_blast/blast_query.rb"
require "scbi_blast/blast_hit.rb"

require 'rexml/document'
require 'rexml/streamlistener'

include REXML
include REXML::StreamListener

# Extracts results from a blast results in XML
# format and uses it to create instances of "BlastQuery" and "BlastHit"
class BlastStreamxmlResult < BlastResult
  
  # Parser initialization
  def initialize(input)
    super(input)

    lines=[]
    
    # some variables for tracking the state of the parse
    @current_query = nil
    @current_hit = nil
    @current_element = nil
    @current_hit_subject_id=''
    @current_hit_acc=''
    @current_hit_full_subject_length=0
    @current_hit_hit_def=''
    
    # @state = nil # (values :in_query,:in_hit)
    
    return if input.empty?
    
    if input.is_a?(Array)
      lines=input.join("\n")
      do_parse(lines)
      
    elsif !input.strip.empty?
      
      if File.exists?(input)
        lines= File.open(input,'r')
        # @lines = fich.readlines
        # fich.close
        do_parse(lines)
        lines.close
      else
        raise "File #{input} doesn't exists"
      end
    end
    
  end
  

  def tag_start(name, attributes)
    # puts "+#{name}: #{attributes}"
    case name
      when 'Iteration'
        @current_query= BlastQuery.new(-1)
        
      when 'Hit'
        @current_hit_subject_id=''
        @current_hit_acc=''
        @current_hit_full_subject_length=0
        @current_hit_hit_def=''
        
      when 'Hsp'
        @current_hit = BlastHit.new(0,0,0,0)
        
        # populate results from hit
        @current_hit.subject_id=@current_hit_subject_id
        @current_hit.full_subject_length=@current_hit_full_subject_length
        @current_hit.definition=@current_hit_hit_def
        @current_hit.acc=@current_hit_acc
      else
        @current_element = name
    end
    
  end

  def tag_end(name)
    
    case name
      when 'Iteration'
        @querys.push @current_query
        @current_query=nil
      when 'Hit'
        @current_hit_subject_id=''
        @current_hit_acc=''
        @current_hit_full_subject_length=0
        @current_hit_hit_def=''
        @current_hit=nil
        
      when 'Hsp'
        @current_hit.set_limits(@current_hit.q_beg,@current_hit.q_end,@current_hit.s_beg,@current_hit.s_end)
        
        @current_query.hits.push @current_hit
        
    end
    
    @current_element=nil
    # puts "-#{name}"

  end

  def text(text)
    
    case @current_element
      
      # values for querys 
      when 'Iteration_query-ID'
        @current_query.query_id=text
      when 'Iteration_query-len'
        @current_query.full_query_length=text.to_i
      when 'Iteration_query-def'
        @current_query.query_def=text
        
      # values for hits
      when 'Hit_id'
        @current_hit_subject_id=text
      when 'Hit_accession'
        @current_hit_acc=text
      when 'Hit_len'
        @current_hit_full_subject_length=text.to_i
      when 'Hit_def'
        @current_hit_hit_def=text
        if @current_hit_hit_def=='No definition line'
          @current_hit_hit_def =@current_hit_subject_id
        end

      # values for HSPs
      

        when 'Hsp_query-from'
          # puts "QBEG1:#{text.to_i}"
          @current_hit.q_beg=text.to_i
          # puts "QBEG2:#{@current_hit.q_beg},#{text.to_i}"
        when 'Hsp_query-to'
          @current_hit.q_end=text.to_i
        when 'Hsp_hit-from'
          @current_hit.s_beg=text.to_i
        when 'Hsp_hit-to'
          @current_hit.s_end=text.to_i
        when 'Hsp_align-len'
          @current_hit.align_len=text.to_i
          @current_hit.ident=(@current_hit.ident/@current_hit.align_len)*100
        when 'Hsp_identity'
          
          @current_hit.ident=(text.to_f)
          # @current_hit.ident=(text.to_f/@current_hit.align_len)*100
          # percent calculation now goes to align-len
        when 'Hsp_gaps'
          @current_hit.gaps=text.to_i
        when 'Hsp_midline'
          @current_hit.mismatches= text.count(' ').to_i - @current_hit.gaps
        when 'Hsp_evalue'
          @current_hit.e_val=text.to_f
          @current_hit.e_val = (@current_hit.e_val*1000).round/1000.0
        when 'Hsp_bit-score'
          @current_hit.bit_score=text.to_f
          @current_hit.bit_score = (@current_hit.bit_score*100).round/100.0
        when 'Hsp_score'
          @current_hit.score =text.to_f
        when 'Hsp_query-frame'
          @current_hit.q_frame = text.to_i
        when 'Hsp_hit-frame'
          @current_hit.s_frame =text.to_i

        when 'Hsp_qseq'
          @current_hit.q_seq = text
        when 'Hsp_hseq'
          @current_hit.s_seq = text
      
    end

    # reset the current element so we don't pick up empty text
    @current_element = nil
  end
  
  def do_parse(lines)
    Document.parse_stream(lines, self)
  end

end
