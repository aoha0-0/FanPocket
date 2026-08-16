# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[terms privacy guide]

  def terms; end

  def privacy; end

  def guide; end
end
