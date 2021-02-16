module Tyrant
  class SignUp < Trailblazer::Operation
    step Model(::User, :new)
    step Contract::Build(constant: Form::Abstract)
    step Contract::Validate()
    step Contract::Persist(method: :sync) # write :email to model.
    step :digest!
    step :save!

    def digest!(options, model:, **)
      auth = Tyrant::Authenticatable.new(model)

      auth.digest!( options["contract.default"].password )
      auth.confirmed!

      auth.sync # write :auth_meta_data field to model.
    end

    def save!(options, model:, **)
      model.save
    end
  end
end
