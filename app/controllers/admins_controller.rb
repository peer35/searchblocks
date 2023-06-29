class AdminsController < ApplicationController
  require 'rsolr'
  require 'csv'

  include Blacklight::Configurable
  include Blacklight::Catalog

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :set_paper_trail_whodunnit
  before_action :set_admin, only: [:show, :edit, :update, :destroy]

  before_action :require_user_authentication_provider
  before_action :verify_user

  solr_config = Rails.application.config_for :blacklight
  @@solr = RSolr.connect :url => solr_config['url'] # get this from blacklight config

  def verify_user
    if current_user.to_s.blank?
      flash[:notice] = I18n.t('admin.need_login') and raise Blacklight::Exceptions::AccessDenied
    elsif Rails.configuration.x.admin_users_email.include? current_user.email
    else
      raise Pundit::NotAuthorizedError
    end
  end

  # GET /admins
  # GET /admins.json
  def index
    @admins = Admin.all
    @destroyed = PaperTrail::Version.where("event = 'destroy'").order(:created_at).reverse

    respond_to do |wants|
      wants.csv do
        render_csv("blocks-#{Time.now.strftime("%Y%m%d")}")
      end
      wants.html do
        render :index
      end
    end
  end

  def render_csv(filename = nil)
    filename ||= params[:action]
    filename += '.csv'

    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain"
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = "0"
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    end

    render :layout => false
  end

  # GET /admins/1
  # GET /admins/1.json
  def show
    redirect_to :controller => 'catalog', action: "show", id: @admin.id
  end

  # GET /admins/new
  def new
    verify_user
    @keyword_list = keyword_list
    @name_list = name_list
    @title_list = Admin.all.map {|a| [a.title, a.id]}
    @admin = Admin.new
  end

  # GET /admins/1/edit
  def edit
    @keyword_list = keyword_list
    @name_list = name_list
    @title_list = Admin.all.map {|a| [a.title, a.id]}

    @versions = @admin.versions
    @current = @admin
    @versionshowing = Hash.new()
    if params[:version]
      @admin = @admin.versions.find(params[:version]).reify
      @versionshowing['status'] = 'previous'
    else
      @admin.creationdate = Time.now
      @versionshowing['status'] = 'current'
    end

    @versionshowing['created_by'] = @admin.user_email
    @versionshowing['created_at'] = @admin.updated_at
    # hier splitblock doen om :searchblocks en :searchblocksystems te genereren?
    @searchblocksystem, @searchblockcontent = splitblock(@admin.searchblocks)
  end


  # POST /admins
  # POST /admins.json
  def create
    params[:kw] ||= []
    params[:nm] ||= []
    params[:al] ||= []
    @admin = Admin.new(admin_params)
    @admin.user_id = current_user.id
    @admin.user_email = current_user.email
    searchblocks = params[:searchblocks]
    searchblocksystems = params[:searchblocksystems]
    respond_to do |format|
      @admin.keywords = params[:kw].to_json
      @admin.creators = params[:nm].to_json
      @admin.also = params[:al].to_json
      @admin.searchblocks = glueblock(searchblocks, searchblocksystems)
      if @admin.save
        #add_to_solr(@admin) #moved to model
        flash[:notice] = "Block was successfully created."
        format.html {redirect_to :controller => 'catalog', action: "show", id: @admin.id}
        format.json {render :show, status: :created, location: @admin}
      else
        format.html {render :new}
        format.json {render json: @admin.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /admins/1
  # PATCH/PUT /admins/1.json
  def update
    params[:kw] ||= []
    params[:nm] ||= []
    params[:al] ||= []
    # TODO: serialize creators, keywords, also and searchblocks for automatic conversion to and from json
    respond_to do |format|
      searchblocks = params[:searchblocks]
      searchblocksystems = params[:searchblocksystems]
      @admin.user_id = current_user.id
      @admin.user_email = current_user.email
      @admin.searchblocks = glueblock(searchblocks, searchblocksystems)
      @admin.keywords = params[:kw].to_json
      @admin.creators = params[:nm].to_json
      @admin.also = params[:al].to_json
      if @admin.update(admin_params)
        # update SOLR
        #add_to_solr(@admin) #moved to model
        flash[:notice] = "Block was successfully updated."
        format.html {redirect_to :controller => 'catalog', action: "show", id: @admin.id}
        format.json {render :show, status: :ok, location: @admin}
      else
        format.html {render :edit}
        format.json {render json: @admin.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /admins/1
  # DELETE /admins/1.json
  def destroy
    #@@solr.delete_by_id @admin.id #moved to model
    #@@solr.commit

    @admin.destroy
    respond_to do |format|

      # format.html { redirect_to admins_url, notice: 'Admin was successfully destroyed.' }
      flash[:notice] = "Block was successfully deleted."
      format.html {redirect_to :controller => 'catalog', action: "index"}
      format.json {head :no_content}
    end
  end

  # GET /admins/indexall
  def indexall
    #add all admins blocks to the solr index with the admin id
    #loop through admins
    respond_to do |format|
      Admin.all.each do |admin|
        admin.save
      end
      flash[:notice] = 'Records reindexed.'
      format.html {redirect_to :controller => 'catalog', action: "index"}
    end
  end

  private

  def keyword_list()
    response = @@solr.get 'select', :params => {
        "facet.field" => "keyword_sm", "rows" => 0, "q" => "*", "facet" => true, "f.keyword_sm.facet.limit" => 1000
    }
    facets = response['facet_counts']['facet_fields']['keyword_sm']
    return facets.values_at(* facets.each_index.select {|i| i.even?}).sort
  end

  def name_list()
    response = @@solr.get 'select', :params => {
        "facet.field" => "names_sm", "rows" => 0, "q" => "*", "facet" => true, "f.names_sm.facet.limit" => 1000
    }
    facets = response['facet_counts']['facet_fields']['names_sm']
    return facets.values_at(* facets.each_index.select {|i| i.even?}).sort
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_admin
    @admin = Admin.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_params
    params.require(:admin).permit(:title, :searchblocks, :creators, :notes, :keywords, :creationdate, :admin_notes)
  end

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
    # TODO: refactor to json format
    searchblocksystem = []
    searchblockcontent = []
    n = 0
    searchblocks.split(';; ').each do |searchblock|
      if searchblock.split(':: ').length > 1
        searchblocksystem[n] = searchblock.split(':: ')[0]
        searchblockcontent[n] = searchblock.split(':: ')[1]
      else
        searchblocksystem[n] = ''
        searchblockcontent[n] = searchblock
      end
      n = n + 1
    end
    return searchblocksystem, searchblockcontent
  end
end

def user_not_authorized
  flash[:alert] = "You are not authorized to perform this action."
  redirect_to(request.referrer || root_path)
end