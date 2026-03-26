require "rails_helper"

RSpec.describe KioskConfigsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/kiosk_configs").to route_to("kiosk_configs#index")
    end

    it "routes to #new" do
      expect(get: "/kiosk_configs/new").to route_to("kiosk_configs#new")
    end

    it "routes to #show" do
      expect(get: "/kiosk_configs/1").to route_to("kiosk_configs#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/kiosk_configs/1/edit").to route_to("kiosk_configs#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/kiosk_configs").to route_to("kiosk_configs#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/kiosk_configs/1").to route_to("kiosk_configs#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/kiosk_configs/1").to route_to("kiosk_configs#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/kiosk_configs/1").to route_to("kiosk_configs#destroy", id: "1")
    end
  end
end
