require 'test_helper'

class Tyrant::ResetPassword < Trailblazer::Operation
  class Request < Trailblazer::Operation

    class GetEmail < Trailblazer::Operation
      include Form
      step Contract::Build(constant: Form::Request)
    end

    step Nested( GetEmail )
    step Contract::Validate()
    step :model!
    step :generate_password!
    step :reset_password!
    step :save!
    step :reset_link!
    step :notify_user!

  end
end

class Tyrant::ResetPassword < Trailblazer::Operation
  class Request::GetEmail < Trailblazer::Operation
    module Form
      class Request < Reform::Form
        # code
      end
    end
  end
end
