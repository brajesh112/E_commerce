require "googleauth"
require "net/http"
require "stringio"

# Sends push notifications through Firebase Cloud Messaging HTTP v1.
# Auth uses a Google service account (JSON), scoped to firebase.messaging.
class FcmPushService
  SCOPE = "https://www.googleapis.com/auth/firebase.messaging".freeze

  class << self
    # Fan a notification out to every device token a user has registered.
    def send_to_user(user, title:, body:, data: {})
      return if user.nil?
      user.device_tokens.pluck(:token).each do |token|
        send_message(token, title, body, data)
      end
    end

    def send_message(token, title, body, data = {})
      uri = URI("https://fcm.googleapis.com/v1/projects/#{project_id}/messages:send")
      payload = {
        message: {
          token: token,
          notification: { title: title, body: body },
          data: data.transform_values(&:to_s)
        }
      }
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{access_token}"
      request["Content-Type"] = "application/json"
      request.body = payload.to_json

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
      prune_token(token) if stale_token?(response)
      response
    rescue StandardError => e
      Rails.logger.error("FCM send failed for token #{token}: #{e.class} #{e.message}")
      nil
    end

    private

    # FCM reports a dead token as 404 NOT_FOUND or 400 UNREGISTERED.
    def stale_token?(response)
      code = response.code.to_i
      code == 404 || (code == 400 && response.body.to_s.include?("UNREGISTERED"))
    end

    def prune_token(token)
      DeviceToken.where(token: token).delete_all
    end

    def access_token
      authorizer.fetch_access_token!["access_token"]
    end

    def authorizer
      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(credentials_json),
        scope: SCOPE
      )
    end

    def credentials_json
      return ENV["FIREBASE_CREDENTIALS_JSON"] if ENV["FIREBASE_CREDENTIALS_JSON"].present?
      File.read(ENV.fetch("FIREBASE_CREDENTIALS_PATH"))
    end

    def project_id
      ENV.fetch("FIREBASE_PROJECT_ID")
    end
  end
end
