module Repos
  module UserRepo
    extend self

    def create_user(attrs)
      code = (SecureRandom.rand * 10000).to_i.to_s
      code = BCrypt::Password.create(code)
      User.create(**attrs, code_hash: code)
    end
  end
end
