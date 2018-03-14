module Tyrant
  class SignUp::GitHub < Trailblazer::Operation
    module Form
      class GitHub < Reform::Form
        feature Reform::Form::Dry

        property :state, virtual: true
        property :code, virtual: true
        property :client_id, virtual: true
        property :client_secret, virtual: true
        property :status, virtual: true

        validation  do
          # TODO: I want to do this, how?
          # def check_app_settings?(options)
          #   errors.add(:client_id, :missing_client_id) unless options['client_id']
          #   errors.add(:client_secret, :missing_client_secret) unless options['client_secret']
          #   errors.add(:status, :missing_status) unless options['status']
          # end

          required(:state).filled
          required(:code).filled
        end
      end
    end
  end
end
