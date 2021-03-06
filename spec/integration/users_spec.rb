require 'rails_helper'

describe "users", :type => :feature do
  it "has the title 'Free to Play Hearthstone Tracker'" do
    visit "/home"
    expect(page).to have_title("Free to Play Hearthstone Tracker")
  end

  it "sets the root to the home controller" do
    visit "/"
    expect(page).to have_title("Free to Play Hearthstone Tracker")
  end

  it "shows each user" do
    omgrr = User.create(name: "omgrr", email: "omgrr@ftp.com", password: "password123")
    bison = User.create(name: "bison", email: "bison@ftp.com", password: "password123")

    visit "/"
    expect(page).to have_selector(".user##{omgrr.id}")
    expect(page).to have_selector(".user##{bison.id}")
  end

  it "shows each user" do
    bison = User.create(name: "bison", email: "bison@ftp.com", password: "password123")
    kevias = User.create(name: "kevias", email: "kevias@ftp.com", password: "password123")
    omgrr = User.create(name: "omgrr", email: "omgrr@ftp.com", password: "password123")

    omgrr.update_attributes(rank: 1)
    bison.update_attributes(rank: 2)
    kevias.update_attributes(rank: 3)

    visit "/"

    expect(page).to have_selector(".user:first-child h4", text: "omgrr")
    expect(page).to have_selector(".user:nth-last-child(2) h4", text: "bison")
    expect(page).to have_selector(".user:last-child h4", text: "kevias")
  end

  it "displays the users name and rank" do
    omgrr = User.create(name: "omgrr", email: "omgrr@ftp.com", password: "password123")
    bison = User.create(name: "bison", email: "bison@ftp.com", password: "password123")
    omgrr.update_attributes(rank: 20)

    visit "/"

    expect(find(".user##{omgrr.id}")).to have_content("omgrr")
    expect(page).to have_selector(".user##{omgrr.id} .rank_20")
    expect(find(".user##{bison.id}")).to have_content("bison")
    expect(page).to have_selector(".user##{bison.id} .rank_25")
  end

  describe "ranks" do
    context "when you are logged in" do
      before do
        @omgrr = User.create(name: "omgrr", email: "omgrr@ftp.com", password: "password123")
        @omgrr.update_attributes(rank: 20)
        sign_in(@omgrr)
      end

      it "lets you 'go down' and displays the correct spite" do
        click_button("#{@omgrr.id}-go-down")

        expect(@omgrr.reload.rank).to eq(19)
        expect(page).to have_selector(".user##{@omgrr.id} .rank_19")
      end

      it "lets you 'go up' and displays the correct spite" do
        click_button("#{@omgrr.id}-go-up")

        expect(@omgrr.reload.rank).to eq(21)
        expect(page).to have_selector(".user##{@omgrr.id} .rank_21")
      end

      it "doesn't show other users rank up and down buttons" do
        bison = User.create(name: "bison", email: "bison@ftp.com", password: "password123")

        visit "/"

        within(".user##{bison.id}") do
          expect(page).to_not have_button("#{bison.id}-go-up")
          expect(page).to_not have_button("#{bison.id}-go-down")
        end
      end

      it "displays a message when you try to go past rank 25" do
        @omgrr.update_attributes(rank: 25)

        click_button("#{@omgrr.id}-go-up")

        expect(@omgrr.reload.rank).to eq(25)
        expect(page).to have_content("Rank cannot go above 25")
      end

      it "displays a message when you try to go past rank 25" do
        @omgrr.update_attributes(rank: 1)
        click_button("#{@omgrr.id}-go-down")

        expect(@omgrr.reload.rank).to eq(1)
        expect(page).to have_content("Rank cannot go below 1")
      end

      it "shows a progress bar based on the rank" do
        within(".user##{@omgrr.id}") do
          expect(page).to have_selector(".progress-bar")
        end
      end

      it "fills the progres bar by 4% when you go down a rank" do
        @omgrr.update_attributes(rank: 24)
        visit "/"

        expect(page).to have_css('.progress-bar[aria_valuenow="4"]')

        click_button("#{@omgrr.id}-go-down")

        expect(page).to have_selector('.progress-bar[aria_valuenow="8"]')

      end

      it "shrinks the progres bar by 4% when you go up a rank" do
        @omgrr.update_attributes(rank: 24)
        visit "/"

        expect(page).to have_css('.progress-bar[aria_valuenow="4"]')

        click_button("#{@omgrr.id}-go-up")

        expect(page).to have_selector('.progress-bar[aria_valuenow="0"]')
      end
    end

    context "when you are not logged in" do
      before do
        @omgrr = User.create(name: "omgrr", email: "omgrr@ftp.com", password: "password123")
        @omgrr.update_attributes(rank: 20)
      end

      it "has no rank buttons" do
        visit "/"

        expect(page).to_not have_button("#{@omgrr.id}-go-up")
        expect(page).to_not have_button("#{@omgrr.id}-go-down")
      end
    end
  end
end
