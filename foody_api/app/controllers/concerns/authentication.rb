module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      render json: {
        message: "Authentication required",
        errors: [ "Please log in to access this resource" ]
      }, status: :unauthorized
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = {
          value: session.id,
          httponly: true,
          same_site: :lax,
          secure: Rails.env.production?
        }
      end
    end

    def terminate_session
      Current.session&.destroy
      cookies.delete(:session_id)
    end

    def current_user
      Current.session&.user
    end
end
