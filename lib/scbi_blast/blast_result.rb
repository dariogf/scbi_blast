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
class BlastResult
  
  attr_accessor :querys
  
  # Parser initialization
  def initialize(input)

    @querys = []

    # if input.is_a?(Array)
    #   lines=input
    # else
    #   fich = File.open(input,'r')
    #   lines = fich.readlines
    #   fich.close
    # end
  end

  def clean_queries!
    @querys=[]
  end

  # inspect results
  def inspect
    res = "Blast results:\n"
    res+= '-'*20
    res+= "\nQuerys: #{@querys.count}\n"
    @querys.each{|q| res+=q.inspect+"\n"}
    return res
  end

  # find query by name
  def find_query(querys,name_q)
    #  newq = querys.find{|q| ( q.find{|h| (h.subject_id)})}
    new_q=nil

    if !querys.empty?
      new_q=querys.find{|q| (q.query_id==name_q)}
    end

    return new_q
  end

  # check if there are querys
  def empty?
    return @querys.empty?
  end
  
  # get query count
  def size
    @querys.size
  end
  
  def compare?(results)
    res = true
    
    @querys.each_with_index  do |q,i|
      res &&= q.compare?(results.querys[i])
    end
    
    return res
  end
  
end
