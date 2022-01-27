namespace :bnpp_tasks do
  desc "Reindex all records"
  task index: :environment do
    Admin.all.each do |admin|
      puts n
      admin.update_solr
      n = n - 1
    end
  end
end
