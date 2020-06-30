module API
  class Mount < Grape::API
    PREFIX = '/api'

    cascade false

    mount V2::Mount => V2::Mount::API_VERSION
  end
end
