require 'spec_helper'

describe User do
  let(:user) { User.create!(:email => 'foo@bar.com', :password => 'zzzz', :password_confirmation => 'zzzz') }

  [1, 2].each do |num|
    describe "#save_service_key#{num}" do
      before(:each) do
        user.send("save_service_key#{num}", :yahoo, 'loveyoulongtime')
      end
      it "should save service key#{num}" do
        user.web_services.last.send("key#{num}").should == 'loveyoulongtime'
      end
      it "should save the service name" do
        user.web_services.last.name.should == 'yahoo'
      end
    end

    describe "#get_service_key#{num}" do
      it "should get service key#{num}" do
        srv = WebService.create!(:name => 'yahoo', "key#{num}".to_sym => "foobar#{num}")
        user.web_services << srv
        user.send("get_service_key#{num}", :yahoo).should == "foobar#{num}"
      end
    end
  end

  describe "#has_service?" do
    it "should detect if a service is present" do
      srv = WebService.create!(:name => 'yahoo')
      user.web_services << srv
      user.has_service?(:yahoo).should == true
    end
    it "should detect if a service is not present" do
      user.has_service?(:yahoo).should == false
    end
  end

end




