class User < ApplicationRecord
  has_many :events
  has_many :attendances, foreign_key: 'attendee_id'
  has_many :attended_events, through: :attendances, source: :attended_event
  has_many :invitations, foreign_key: 'invited_id'
  has_many :inviting_events, through: :invitations, source: :inviting_event

  def upcoming_attended_events
    attended_events.where('date > ?', Time.now.to_date)
  end

  def past_attended_events
    attended_events.where('date < ?', Time.now.to_date)
  end
end
