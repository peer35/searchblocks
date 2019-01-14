class UpdateBlockFormatting < ActiveRecord::Migration[5.0]
  def up
    #execute "update admins set searchblocks = replace(searchblocks, ': ', ':: ')"
    # loop through all blocks
    # @admin.searchblocks = glueblock(searchblocks, searchblocksystems)
    # @searchblocksystem, @searchblockcontent = splitblock(@admin.searchblocks)
    # @admin.update
    Admin.all.each do |admin|
      searchblocksystems, searchblocks = splitblock(admin.searchblocks)
      puts admin.searchblocks
      searchblocks = glueblock(searchblocks, searchblocksystems)
      puts searchblocks
      #id = admin.id
      #Admin.update(id, :searchblocks => searchblocks)
      admin.update(:searchblocks => searchblocks)
    end
  end

  private
  def glueblock(searchblocks, searchblocksystems)
    sbs = []
    n = 0
    searchblocks.each do |sb|
      if searchblocksystems[n] == ''
        sbs[n] = sb
      else
        sbs[n] = searchblocksystems[n] + ':: ' + sb
      end
      n = n + 1
    end
    return sbs.join(';; ')
  end

  def splitblock(searchblocks)
    searchblocksystem = []
    searchblockcontent = []
    n = 0
    searchblocks.split(';; ').each do |searchblock|
      if searchblock.split(': ').length > 1
        searchblocksystem[n] = searchblock.split(': ')[0]
        searchblockcontent[n] = searchblock.split(': ')[1]
      else
        searchblocksystem[n] = ''
        searchblockcontent[n] = searchblock
      end
      n = n + 1
    end
    return searchblocksystem, searchblockcontent
  end
end
