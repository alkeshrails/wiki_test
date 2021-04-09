class PagesController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.js do
        wp = Wikipedia::Base.new
        @page_data = wp.get_page_data(params[:title])
      end
    end
  end
end
