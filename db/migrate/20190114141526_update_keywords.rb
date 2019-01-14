class UpdateKeywords < ActiveRecord::Migration[5.0]
  def up
    Admin.all.each do |admin|
      keywords = []
      puts admin.keywords
      c = JSON::parse(admin.keywords)
      c.each do |kw|
        kw = kw.gsub('Wiley-Cochrane Library (CLib)', 'Wiley/Cochrane Library (CLib)')
        kw = kw.gsub('Clarivate Analytics-Web of Science (WoS)', 'Clarivate Analytics/Web of Science (WoS)')
        kw = kw.gsub(/EBSCO-CINAHL/, 'EBSCO/CINAHL')
        kw = kw.gsub(/EBSCO-PsycInfo (PI)/, 'EBSCO/PsycInfo (PI)')
        kw = kw.gsub(/EBSCO-SportDiscus (SD)/, 'EBSCO/SportDiscus (SD)')
        kw = kw.gsub(/OVID-ERIC/, 'OVID/ERIC')
        kw = kw.gsub(/OVID-Pilots/, 'OVID/Pilots')
        kw = kw.gsub(/OVID-PsycInfo (PI)/, 'OVID/PsycInfo (PI)')
        kw = kw.gsub('Web of Knowledge (Wok)-Medline', 'Web of Knowledge (Wok)/Medline')
        puts kw
        keywords.append(kw)
      end
      admin.update(:keywords => keywords.to_json)
      puts admin.keywords
    end
  end
end
