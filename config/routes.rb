Rails.application.routes.draw do

  resources :admins, defaults: {format: 'html'}

  resource :admins do
    get 'admin/indexall' => 'admins#indexall'
    get 'admin/updateall' => 'admins#updateall'
  end

  mount Blacklight::Engine => '/'
  Blacklight::Marc.add_routes(self)
  root to: "catalog#index"
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  post "versions/:id/revert" => "versions#revert", :as => "revert_version"


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
