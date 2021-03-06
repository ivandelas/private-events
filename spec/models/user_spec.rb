require 'rails_helper'

RSpec.describe User, type: :model do
  it 'creates a user' do
    expect { User.create(name: 'bob') }.not_to raise_error
  end

  before do
    @user = User.create(name: 'jen')
    @event = Event.create(
      description: 'party', user_id: @user.id
    )
  end

  it 'add a new user' do
    count = User.count
    User.create(name: 'stuart')
    expect(User.count).to eq(count + 1)
  end

  it 'has many events' do
    expect(@user.respond_to?(:events)).to be_truthy
    expect(@user.events).to include(@event)
  end

  it 'has many attended_events' do
    expect(@user).to be_respond_to(:attended_events)
    user = User.create(name: 'crystal')
    event = user.events.create(description: 'small meeting')
    @user.attended_events << event
    expect(@user.attended_events).to include(event)
  end

  it 'invites users' do
    expect(@user).to be_respond_to(:invite)
    other_user = User.create(name: 'lana')
    @user.invite(other_user, @event)
    expect(other_user.inviting_events).to include(@event)
    expect(@event.inviteds).to include(other_user)
  end

  it 'does not invite user if already in inviteds' do
    expect(@user).to be_respond_to(:invite)
    other_user = User.create(name: 'lana')
    @user.invite(other_user, @event)
    expect(other_user.inviting_events).to include(@event)
    expect(@event.inviteds).to include(other_user)
    expect(@event.inviteds.count).to eq(1)
    @user.invite(other_user, @event)
    expect(@event.inviteds.count).to eq(1)
  end

  it 'attends events' do
    expect(@user).to be_respond_to(:attend)
    other_user = User.create(name: 'lana')
    @user.invite(other_user, @event)
    other_user.attend(@event)
    expect(@event.attendees).to include(other_user)
    expect(other_user.attended_events).to include(@event)
  end

  it 'does not attend event if already attended' do
    expect(@user).to be_respond_to(:attend)
    other_user = User.create(name: 'lana')
    @user.invite(other_user, @event)
    other_user.attend(@event)
    expect(@event.attendees).to include(other_user)
    expect(other_user.attended_events).to include(@event)
    expect(other_user.attended_events.count).to eq(1)
    other_user.attend(@event)
    expect(other_user.attended_events.count).to eq(1)
  end

  it 'has past_attended_events' do
    now = Time.now.to_date
    user = User.create(name: 'crystal')

    event1 = user.events.create(
      description: 'small meeting',
      date: Date.new(now.year, now.month, now.day - 2)
    )

    event2 = user.events.create(
      description: 'family meeting',
      date: Date.new(now.year, now.month, now.day - 6)
    )

    event3 = user.events.create(
      description: 'soccer game',
      date: Date.new(now.year, now.month, now.day + 1)
    )

    events = [event1, event2, event3]
    events.each { |e| @user.attended_events << e }
    old_events = @user.attended_events.where('date < ?', Time.now.to_date)
    expect(@user.respond_to?(:past_attended_events)).to be_truthy
    expect(@user.past_attended_events).to eq(old_events)
    expect(@user.past_attended_events.count).to eq(2)
  end

  it 'has upcoming_attended_events' do
    now = Time.now.to_date
    user = User.create(name: 'crystal')

    event1 = user.events.create(
      description: 'small meeting',
      date: Date.new(now.year, now.month, now.day + 2)
    )

    event2 = user.events.create(
      description: 'family meeting',
      date: Date.new(now.year, now.month, now.day + 6)
    )

    event3 = user.events.create(
      description: 'soccer game',
      date: Date.new(now.year, now.month, now.day - 1)
    )

    events = [event1, event2, event3]
    events.each { |e| @user.attended_events << e }
    upcoming_events = @user.attended_events.where('date >= ?', Time.now.to_date)
    expect(@user.respond_to?(:past_attended_events)).to be_truthy
    expect(@user.upcoming_attended_events).to eq(upcoming_events)
    expect(@user.upcoming_attended_events.count).to eq(2)
  end

  it 'has many inviting_events' do
    user = User.create(name: 'sam')
    other_user = User.create(name: 'jhon')
    event1 = other_user.events.create(description: 'party 1')
    event2 = other_user.events.create(description: 'party 2')
    event3 = other_user.events.create(description: 'party 3')
    expect(user).to be_respond_to(:inviting_events)
    user.inviting_events << event1
    user.inviting_events << event2
    user.inviting_events << event3
    expect(user.inviting_events).to include(event1)
    expect(user.inviting_events).to include(event2)
    expect(user.inviting_events).to include(event3)
    expect(user.inviting_events.count).to eq(3)
  end
end
