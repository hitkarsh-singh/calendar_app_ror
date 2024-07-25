# app/serializers/event_serializer.rb
class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_time, :end_time, :duration

  def duration
    return nil unless object.start_time && object.end_time
    ((object.end_time - object.start_time) / 1.hour).round(2)
  end
end
