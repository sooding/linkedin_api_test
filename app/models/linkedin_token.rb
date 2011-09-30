class LinkedinToken < ConsumerToken

  def self.find_or_create_from_access_token(user,access_token)
    secret = access_token.respond_to?(:secret) ? access_token.secret : nil

    if user
      token = self.find_or_initialize_by_user_id_and_token(user.id, access_token.token)
    else
      token = self.find_or_initialize_by_token(access_token.token)
    end

    # set or update the secret
    token.secret = secret
    token.save! if token.new_record? or token.changed?
    token
  end

end

