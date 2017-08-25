require "test_helper"

class GitHubTest < MiniTest::Spec

  describe "Test policy and failure message" do

    it "false policy" do
      res = Tyrant::SignUp::GitHub.({})

      res.failure?.must_equal true
      res["result.policy.default"].success?.must_equal false
    end

    it "failure messages" do
      # state
      res = Tyrant::SignUp::GitHub.({})

      res.failure?.must_equal true
      res["failure_message"].must_equal "State has not been set"

      # client_id
      res = Tyrant::SignUp::GitHub.({state: "login"}, "state" => "login")

      res.failure?.must_equal true
      res["failure_message"].must_equal "Client_id has not been set"

      # client_secret
      res = Tyrant::SignUp::GitHub.({state: "login"}, "state" => "login", "client_id" => "client_id")

      res.failure?.must_equal true
      res["failure_message"].must_equal "Client_secret has not been set"
    end

  end

end
