require "test_helper"

class AuthenticatableTest < MiniTest::Spec
  Authenticatable = Tyrant::Authenticatable
  User = Struct.new(:auth_meta_data)

  describe "#confirmable?" do
    # nothing initialized.
    it { _(Authenticatable.new(User.new).confirmable?).must_equal false }
    it { _(Authenticatable.new(User.new({})).confirmable?).must_equal false }
    it { _(Authenticatable.new(User.new({confirmation_token: nil})).confirmable?).must_equal false }
    # token given.
    it { _(Authenticatable.new(User.new({confirmation_token: "yo!"})).confirmable?).must_equal true }


    it { _(Authenticatable.new(User.new({confirmation_token: "yo!"})).confirmable?(nil)).must_equal false }
    it { _(Authenticatable.new(User.new({})).confirmable?("yo!")).must_equal false }
    it { _(Authenticatable.new(User.new({confirmation_token: "yo!"})).confirmable?("yo!")).must_equal true }
    # TODO: add expiry.
  end

  describe "#confirmable!" do
    it do
      auth = Authenticatable.new(User.new)
      _(auth.confirmable?).must_equal false
      _(auth.confirmable!).must_equal auth
      _(auth.confirmable?).must_equal true
      _(auth.auth_meta_data.confirmation_token).must_be_kind_of String
    end
  end

  describe "#confirmed? / #cofirmed!" do
    # blank.
    it { _(Authenticatable.new(User.new).confirmed?).must_equal false }
    # with token.
    it { _(Authenticatable.new(User.new({confirmation_token: "yo!"})).confirmed?).must_equal false }

    it do
      auth = Authenticatable.new(User.new({confirmation_token: "yo!"}))
      auth.confirmed!
      # confirmed?
      _(auth.confirmed?).must_equal true
      # confirmed_at.
      _(auth.auth_meta_data.confirmed_at).must_be_kind_of DateTime
    end
  end

  describe "#confirmation_token" do
    it do
      auth = Authenticatable.new(User.new)
      assert_nil auth.confirmation_token
      auth.confirmable!
      _(auth.confirmation_token).must_be_kind_of String
    end
  end


  describe "#digest!" do
    it do
      auth = Authenticatable.new(User.new)
      assert_nil auth.digest
      auth.digest!("secret: Trailblazer rules!")
      assert auth.digest == "secret: Trailblazer rules!"
      _(auth.digest).must_be_instance_of BCrypt::Password

      # TODO: sync must be called!
    end
  end

  describe "#digest?" do
    it do
      auth = Authenticatable.new(User.new)
      _(auth.digest?("secret: Trailblazer rules!")).must_equal false

      auth.digest!("secret: Trailblazer rules!")
      _(auth.digest?("secret: Trailblazer sucksssss!")).must_equal false
      _(auth.digest?("secret: Trailblazer rules!")).must_equal true
    end
  end
end
