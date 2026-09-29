class PushController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  # The service worker is a legitimately-served, same-origin JS response;
  # Rails' cross-origin JS guard would otherwise reject it.
  skip_forgery_protection only: :service_worker

  # Served at the site root so the service worker's scope covers every page.
  # Rendered (not a static file) so the Firebase web config comes from ENV.
  def service_worker
    render template: "push/service_worker", layout: false,
           content_type: "text/javascript", formats: [:js]
  end
end
