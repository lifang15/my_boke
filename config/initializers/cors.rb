allowed_origins = Array(
  Rails.configuration.x.blog.dig(:cors, :allowed_origins)
).compact

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*allowed_origins)

    resource "/api/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
