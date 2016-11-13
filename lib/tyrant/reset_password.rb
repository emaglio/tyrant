require 'securerandom'
require "trailblazer/operation"
require "trailblazer/operation/model"
require "active_model"
require "reform/form/validate"
require "reform/form/active_model/validations"
require "pony"

module Tyrant
  class ResetPassword < trailblazer::Operation
    include Model
    model User, :find
    
    def process(params)
      new_authentication(model)
      contract.save
    end

  private
    def new_authentication(model)
      auth = Tyrant::Authenticatable.new(model)
      new_password = generate_password
      auth.digest!(new_password) # contract.auth_meta_data.password_digest = ..
      auth.confirmed!
      auth.sync
      notify_user(model.email, new_password)
    end

    def generate_password
      # return SecureRandom.base64
      return "NewPassword"
    end

    def notify_user(email, new_password)
      Tyrant::Mailer.new()
      Pony.mail({ to: email,
                  subject: "Reset password for TRB Blog",
                  body: "Hi there, here your temporary password: #{new_password}. We suggest you to modify this password ASAP. Cheers",
                })
    end
  end

  class Mailer 
    def initialize
      Pony.options = {
                from: "admin@email.com",
                via: :smtp, 
                via_options: {address: "smtp.gmail.com", 
                port: "587",
                domain: 'localhost:3000', 
                enable_starttls_auto: true, 
                # ssl: true, 
                user_name: "admin@email.com", 
                password: "password", 
                authentication: :login} 
      }
    end
  end
end