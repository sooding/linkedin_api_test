OAUTH_CONFIG = YAML.load_file('config/oauth.yml')

def linkedin_client
  return @linkedin_client if @linkedin_client
  client = LinkedIn::Client.new(OAUTH_CONFIG[:key], OAUTH_CONFIG[:secret])
  client.authorize_from_access(OAUTH_CONFIG[:auth_key1], OAUTH_CONFIG[:auth_key2])
  @linkedin_client = client
end
