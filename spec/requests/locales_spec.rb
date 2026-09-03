require "rails_helper"

RSpec.describe "Locale switching", type: :request do
  it "switches the UI language and keeps it for later requests" do
    get new_session_path
    expect(response.body).to include("Forgot password?")

    get locale_path("it"), headers: { "HTTP_REFERER" => new_session_url }
    expect(response).to redirect_to(new_session_path)

    get new_session_path
    expect(response.body).to include("Accedi")
    expect(response.body).to include("Password dimenticata?")
    expect(response.body).not_to include("Forgot password?")

    get locale_path("fr")
    get new_session_path
    expect(response.body).to include("Mot de passe oublié ?")
  end

  it "falls back to the default locale for a session that never chose one" do
    get new_session_path
    expect(response.body).to include("Log in").or include("Log In")
  end
end
