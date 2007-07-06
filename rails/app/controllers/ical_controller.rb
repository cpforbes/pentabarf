require 'icalendar'

class IcalController < ApplicationController

  def conference
    conf = Conference.select_single({:acronym=>params[:id]})
    tz = View_time_zone.select_single({:time_zone_id => conf.time_zone_id, :language_id => 120})
    tz_offset = tz.tag.match(/^[^0-9]+([+-]\d+)$/)[1].to_i
    lang = Language.select_single({:language_id=>@current_language_id})
    rooms = View_room.select({:conference_id=>conf.conference_id,:language_id=>lang.language_id})
    events = View_schedule_simple.select({:conference_id=>conf.conference_id})

    cal = Icalendar::Calendar.new
    cal.prodid "-//Pentabarf//Schedule//#{lang.tag.upcase}"
    cal.timezone do
      tzid tz.tag
      tzname tz.name
    end
    events.each do | event |
      cal.event do
        uid "#{event.event_id}@#{conf.acronym}@pentabarf.org"
        dtstart "TZID=#{tz.tag}:" + event.start_datetime
        dtend "TZID=#{tz.tag}:" + event.end_datetime
        duration sprintf( 'PT%dH%02dM', event.duration.hour, event.duration.min )
        summary event.title + ( event.subtitle ? " - #{event.subtitle}" : '')
        description event.abstract
        add_category "Lecture"
        status "CONFIRMED"
        url "#{conf.export_base_url}events/#{event.event_id}.#{lang.tag}.html"
        location event.room
      end
    end
    render(:text=>cal.to_ical)
  end

end

