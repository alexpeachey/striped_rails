class WebhooksController < ApplicationController
  skip_before_filter :require_login

  def create
    @processor = WebhookProcessor.new
    @processor.process(request.body.read)

    head :ok
  end

end