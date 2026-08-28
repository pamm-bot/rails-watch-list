module AuthenticationHelpers
  # Signs a user in for a controller spec by creating a real Session
  # record and setting the signed cookie the Authentication concern
  # reads, the same way SessionsController#create does it.
  def sign_in_as(user)
    session = user.sessions.create!
    cookies.signed[:session_id] = session.id
  end
end
