class Admin < ApplicationRecord
  has_paper_trail
  #serialize :keywords, Array

  after_save :update_solr

  def update_solr
    admin = self
    solr_config = Rails.application.config_for :blacklight
    @@solr = RSolr.connect :url => solr_config['url'] # get this from blacklight config

    keyword_sm = JSON::parse(admin.keywords)
    names_sm = JSON::parse(admin.creators)
    also_sm = []
    logger.debug @admin
    unless admin.also.nil?
      also_ids = JSON::parse(admin.also)
      also_sm = []
      # (also store the id??)
      also_ids.each do |id|
        also_sm.push(Admin.find(id).title)
      end
    end


    @@solr.add :title_s => admin.title, :keyword_sm => keyword_sm, :names_sm => names_sm, :also_sm => also_sm, :notes_s => admin.notes,
               :searchblock_s => admin.searchblocks, :date_s => admin.creationdate.to_s[0, 10], :date_dt => admin.creationdate, :id => admin.id
    @@solr.commit
  end

end
