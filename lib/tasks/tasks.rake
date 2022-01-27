namespace :tasks do
  desc "Reindex all records"
  task index: :environment do
    n = Admin.count
    Admin.all.each do |admin|
      puts n
      admin.update_solr
      n = n - 1
    end
  end
end
