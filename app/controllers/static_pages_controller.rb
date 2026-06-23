class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:terms, :privacy]

  def terms; end

  def privacy; end
end
