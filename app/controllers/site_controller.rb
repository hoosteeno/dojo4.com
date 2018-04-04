class SiteController < ::ApplicationController
  def index
    render :body => '42'
  end
end
