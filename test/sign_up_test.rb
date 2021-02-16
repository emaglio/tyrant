require "test_helper"

class SessionSignUpTest < MiniTest::Spec
  describe "Abstract, no password confirmation" do
    it 'is successful' do
      res = Tyrant::SignUp.(params: { email: "selectport@trb.to", password: "123123" } )

      _(res.success?).must_equal true
      _(res[:model].email).must_equal "selectport@trb.to"

      assert Tyrant::Authenticatable.new(res[:model]).digest == "123123"
      _(Tyrant::Authenticatable.new(res[:model]).confirmed?).must_equal true
      _(Tyrant::Authenticatable.new(res[:model]).confirmable?).must_equal false
    end

    it "empty fields" do
      res = Tyrant::SignUp.(params: { email: "", password: "" })

      _(res.failure?).must_equal true
      _(res["result.contract.default"].errors.messages.inspect).must_equal "{:email=>[\"must be filled\", \"Wrong format\"], :password=>[\"must be filled\"]}"
    end

    it "requires unique email" do
      Tyrant::SignUp.(params: {email: "manu@trb.to", password: "123123"})

      res = Tyrant::SignUp.(params: {email: "manu@trb.to", password: "1231235"})

      _(res.failure?).must_equal true
      _(res["result.contract.default"].errors.messages.inspect).must_equal "{:email=>[\"This email has been already used\"]}"
    end
  end


  it 'signup successfully' do
    res = Tyrant::SignUp::Confirmed.(params: { email: "selectport@trb.org", password: "123123", confirm_password: "123123" })

    _(res.success?).must_equal true
    _(res[:model].email).must_equal "selectport@trb.org"

    assert Tyrant::Authenticatable.new(res[:model]).digest == "123123"
    _(Tyrant::Authenticatable.new(res[:model]).confirmed?).must_equal true
    _(Tyrant::Authenticatable.new(res[:model]).confirmable?).must_equal false
  end

  it "not filled out" do
    res = Tyrant::SignUp::Confirmed.(params: {email: "", password: "", confirm_password: ""})

    _(res.failure?).must_equal true
    _(res["result.contract.default"].errors.messages.inspect).must_equal "{:email=>[\"must be filled\", \"Wrong format\"], :password=>[\"must be filled\"], :confirm_password=>[\"must be filled\"]}"
  end

  it "password mismatch" do
    res = Tyrant::SignUp::Confirmed.(params:{email: "user@trb.org", password: "123123", confirm_password: "Wrong because drunk"})

    _(res.failure?).must_equal true
    _(res["result.contract.default"].errors.messages.inspect).must_equal "{:confirm_password=>[\"Passwords are not matching\"]}"
  end

  it "unique email" do
    res = Tyrant::SignUp::Confirmed.(params: {email: "user2@trb.org", password: "123123", confirm_password: "123123"})

    _(res.success?).must_equal true
    _(res[:model].email).must_equal "user2@trb.org"

    res = Tyrant::SignUp::Confirmed.(params: {email: "user2@trb.org", password: "123123", confirm_password: "123123"})

    _(res.failure?).must_equal true
    _(res["result.contract.default"].errors.messages.inspect).must_equal "{:email=>[\"This email has been already used\"]}"
  end

end
