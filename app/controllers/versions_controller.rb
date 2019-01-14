class VersionsController < ApplicationController
  def revert
    @version = PaperTrail::Version.find(params[:id])
    @version.reify.save!
    redirect_to :controller => 'admins', action: "edit", id: @version.item_id, :notice => "Undid destroy. Submit to add back to the index"
  end
end
