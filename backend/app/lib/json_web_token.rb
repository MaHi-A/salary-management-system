class JsonWebToken
  ALGORITHM = "HS256"

  class << self
    def encode(payload, exp: 24.hours.from_now)
      payload = payload.merge(exp: exp.to_i)
      JWT.encode(payload, secret, ALGORITHM)
    end

    def decode(token)
      body = JWT.decode(token, secret, true, algorithm: ALGORITHM).first
      ActiveSupport::HashWithIndifferentAccess.new(body)
    rescue JWT::DecodeError
      nil
    end

    private

    def secret
      Rails.application.secret_key_base
    end
  end
end
