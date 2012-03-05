require "spec_helper"

describe SessionsController do
  describe "routing" do
    it "routes to #new" do
      get("/sign-in").should route_to("sessions#new")
    end

    it "routes to #create" do
      post("/session").should route_to("sessions#create")
    end

    it "routes to #destroy" do
      get("/sign-out").should route_to("sessions#destroy")
    end
  end
end