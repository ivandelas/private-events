require 'rails_helper'

RSpec.describe "CreateEvents", type: :system do
  before do
    driven_by(:rack_test)
  end

  it 'creates an event' do
    visit(login_path)
    fill_in('Name', with: 'bob')
    find('input[type="submit"]').click
    visit(new_event_path)
    expect(page).to have_current_path(new_event_path)
    expect(page).to have_content('Description')
    expect(page).to have_selector('form input[name="event[description]"')
    expect(page).to have_selector('form input[type="text"')
    expect(page).to have_content('Date')
    expect(page).to have_selector('form input[type="date"]')
    expect(page).to have_selector('form input[type="submit"]')
    fill_in('Description', with: 'party')
    fill_in('Date', with: '2020-01-25')
    count = Event.count
    click_on('Create Event')
    expect(Event.count).to eq(count + 1)
    expect(page).to have_current_path(event_path(Event.last))
  end
end
