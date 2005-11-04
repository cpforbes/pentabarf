module Momomoto
  class View_schedule_event < Base
    def initialize
      super
      @domain = 'event'
      @fields = {
        :event_id => Datatype::Integer.new( {} ),
        :conference_id => Datatype::Integer.new( {} ),
        :title => Datatype::Varchar.new( {:length=>128} ),
        :subtitle => Datatype::Varchar.new( {:length=>256} ),
        :abstract => Datatype::Text.new( {} ),
        :description => Datatype::Text.new( {} ),
        :day => Datatype::Smallint.new( {} ),
        :duration => Datatype::Interval.new( {} ),
        :start_time => Datatype::Interval.new( {} ),
        :start_datetime => Datatype::Timestamp.new( {} ),
        :real_starttime => Datatype::Time.new( {} ),
        :room_id => Datatype::Integer.new( {} ),
        :translated_id => Datatype::Integer.new( {} ),
        :event_type_id => Datatype::Integer.new( {} ),
        :event_type => Datatype::Varchar.new( {} ),
        :event_type_tag => Datatype::Varchar.new( {:length=>32} ),
        :conference_track_id => Datatype::Integer.new( {} ),
        :conference_track => Datatype::Varchar.new( {} ),
        :conference_track_tag => Datatype::Varchar.new( {:length=>32} ),
        :language_id => Datatype::Integer.new( {} ),
        :language => Datatype::Varchar.new( {} ),
        :language_tag => Datatype::Varchar.new( {:length=>32} ),
        :person_id => Datatype::Integer.new( {} ),
        :name => Datatype::Varchar.new( {} )
      }
    end
  end
end
