require "test_helper"

class ChangePasswordTest < MiniTest::Spec
  it 'wrong input' do
    res = Tyrant::SignUp::Confirmed.(
      params: {
        email: "changewrong@trb.org",
        password: "123123",
        confirm_password: "123123",
      }
    )
    _(res.success?).must_equal true
    _(res[:model].email).must_equal "changewrong@trb.org"

    assert Tyrant::Authenticatable.new(res[:model]).digest == "123123"
    _(Tyrant::Authenticatable.new(res[:model]).confirmed?).must_equal true
    _(Tyrant::Authenticatable.new(res[:model]).confirmable?).must_equal false

    res = Tyrant::ChangePassword.(params: {email: "wrong@trb.org", password: "wrong"})

    _(res.failure?).must_equal true
    _(res["result.contract.default"].errors.messages.inspect).must_equal "{:email=>[\"User not found\"], :password=>[\"Wrong Password\"], :new_password=>[\"must be filled\"], :confirm_new_password=>[\"must be filled\"]}"
  end

  it "wrong new password" do
     res = Tyrant::SignUp::Confirmed.(
      params: {
        email: "wrongpassword@trb.org",
        password: "123123",
        confirm_password: "123123",
      }
    )
    _(res.success?).must_equal true
    _(res[:model].email).must_equal "wrongpassword@trb.org"

    assert Tyrant::Authenticatable.new(res[:model]).digest == "123123"
    _(Tyrant::Authenticatable.new(res[:model]).confirmed?).must_equal true
    _(Tyrant::Authenticatable.new(res[:model]).confirmable?).must_equal false

    res = Tyrant::ChangePassword.(params: {email: "wrongpassword@trb.org", password: "123123", new_password: "123123", confirm_new_password: "different"})

    _(res.failure?).must_equal true
    _(res["result.contract.default"].errors.messages.inspect).must_equal "{:new_password=>[\"New password can't match the old one\"], :confirm_new_password=>[\"The New Password is not matching\"]}"
  end

  it "false policy" do
    user1 = Tyrant::SignUp::Confirmed.(
      params: {
        email: "user1@trb.org",
        password: "123123",
        confirm_password: "123123",
      }
    )
    _(user1.success?).must_equal true
    _(user1[:model].email).must_equal "user1@trb.org"

    assert Tyrant::Authenticatable.new(user1[:model]).digest == "123123"
    _(Tyrant::Authenticatable.new(user1[:model]).confirmed?).must_equal true
    _(Tyrant::Authenticatable.new(user1[:model]).confirmable?).must_equal false

    user2 = Tyrant::SignUp::Confirmed.(
      params: {
        email: "user2@trb.org",
        password: "123123",
        confirm_password: "123123",
      }
    )
    _(user2.success?).must_equal true
    _(user2[:model].email).must_equal "user2@trb.org"

    RaiseNoError = -> {}

    #user2 trying to change password
    res = Tyrant::ChangePassword.(
      params: {
        email: "user1@trb.org",
        password: "123123",
        new_password: "NewPassword",
        confirm_new_password: "NewPassword"
      },
     current_user: user2[:model]
    )

    _(res.failure?).must_equal true
    _(res["result.policy.default"].success?).must_equal false
    assert Tyrant::Authenticatable.new(user1[:model]).digest == "123123"
    _(Tyrant::Authenticatable.new(user1[:model]).confirmed?).must_equal true
  end

  it 'change password successfully' do
    user = Tyrant::SignUp::Confirmed.(
      params: {
        email: "change@trb.org",
        password: "123123",
        confirm_password: "123123",
      }
    )

    _(user.success?).must_equal true
    _(user[:model].email).must_equal "change@trb.org"

    assert Tyrant::Authenticatable.new(user[:model]).digest == "123123"
    _(Tyrant::Authenticatable.new(user[:model]).confirmed?).must_equal true
    _(Tyrant::Authenticatable.new(user[:model]).confirmable?).must_equal false

    res = Tyrant::ChangePassword.(
      params: {
        email: "change@trb.org",
        password: "123123",
        new_password: "NewPassword",
        confirm_new_password: "NewPassword"
      },
     current_user: user[:model]
    )

    _(res.success?).must_equal true
    _(res[:model].email).must_equal "change@trb.org"

    assert Tyrant::Authenticatable.new(res[:model]).digest != "123123"
    assert Tyrant::Authenticatable.new(res[:model]).digest == "NewPassword"
    _(Tyrant::Authenticatable.new(res[:model]).confirmed?).must_equal true
    _(Tyrant::Authenticatable.new(res[:model]).confirmable?).must_equal false
  end
end
