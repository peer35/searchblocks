module ApplicationHelper
  def format_block options = {}
    options[:document] # the original document
    options[:field] # the field to render
    options[:value] # the value of the field

    newval = ''

    #link_to options[:value], options[:value]

    arr = options[:value][0].split(';;')
    newval = ''
    arr.each do |v|
      arr2 = v.split(': ', 2)

      if (arr2.length > 1)
        block = arr2[0] + ':<br><pre><code>' + arr2[1] + '</code></pre>'
      else
        block = '<pre><code>' + v + '</code></pre>'


      end
      newval = newval + block
    end


    options[:value] = newval
  end
end
