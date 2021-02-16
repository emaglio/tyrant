require 'trailblazer'
require 'tyrant/operation/mailer'
require 'tyrant/operation/get_email'

module Tyrant
  class ResetPassword < Trailblazer::Operation
    step Subprocess(Tyrant::GetEmail)
    step Trailblazer::Operation::Contract::Validate()
    fail :show_errors!, fast_track: true
    step :model!
    step :generate_password!
    step :new_authentication!
    step :notify_user!

    def show_errors!(_ctx, *)
      Railway.fail_fast!
    end

    def model!(ctx, params:, **)
      ctx[:model] = User.find_by(email: params[:email])
    end

    def generate_password!(ctx, generator: PasswordGenerator,  **)
      ctx["new_password"] = generator.()
    end

    def new_authentication!(ctx, model:, new_password:, **)
      auth = Tyrant::Authenticatable.new(model)
      auth.digest!(new_password)
      auth.sync
      model.save
    end

    def notify_user!(ctx, model:, new_password:, mailer: Mailer, via: :smtp,  **)
      mailer.(params: { email: model.email, new_password: new_password }, "via" => via)
    end

    PasswordGenerator = -> { SecureRandom.base64[0,8] }

  end
end
