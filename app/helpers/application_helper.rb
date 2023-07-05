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
      arr2 = v.split(':: ', 2)

      if (arr2.length > 1)
        block = arr2[0] + ':<br><pre>' + arr2[1] + '</pre>'
      else
        block = '<pre>' + v + '</pre>'
      end
      newval = newval + block
    end


    options[:value] = newval
  end

  def semicolon_join_helper args
    args[:document][args[:field]].join('; ').html_safe
  end

  def also_helper args
    arr=args[:document][args[:field]]
    urls=[]
    arr.each do |t|
      id=Admin.find_by(:title => t).id
      urls.push(link_to(t, solr_document_path(id)))
    end
    urls.join('; ').html_safe
  end
end
