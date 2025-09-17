class StaticPagesController < ApplicationController
  def top
    Rails.logger.warn("### CTRL_HIT #{Time.now.to_f}")
    render plain: "controller hit #{Time.now.to_i}"
  end
end
