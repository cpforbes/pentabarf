# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def localize_tag( tag )
    localized = Momomoto::View_ui_message.find({:tag=>tag, :language_id=>Momomoto::ui_language_id})
    localized.length == 1 ? localized.name : tag
  end

  def schedule_table( conference, events )
    table = []
    timeslot_seconds = conference.timeslot_duration.hour * 3600 + conference.timeslot_duration.min * 60
    slots_per_day = ( 24 * 60 * 60 ) / timeslot_seconds
    start = (conference.day_change.hour * 3600) + (conference.day_change.min * 60) + conference.day_change.sec
    # create an array for each day
    conference.days.times do | i | table[i] = [] end
    # fill array with times
    table.each_with_index do | day_table, day |
      current = 0
      while current < 24 * 60 * 60
        table[day].push( [ sprintf("%02d:%02d", ((current + start)/3600)%24, ((current + start)%3600)/60 ) ] )
        current += timeslot_seconds
      end
    end
    events.each do | event |
      slots = (event.duration.hour * 3600 + event.duration.min * 60)/timeslot_seconds
      start_slot = (event.start_time.hour * 3600 + event.start_time.min * 60) / timeslot_seconds
      table[event.day - 1][start_slot][event.room_id] = {:event_id => event.event_id, :slots => slots}
      slots.times do | i |
        next if i < 1
        # check whether the event spans multiple days
        if (start_slot + i) >= slots_per_day
          if (start_slot + i)%slots_per_day == 0
            table[event.day - 1 + (start_slot + i)/slots_per_day][(start_slot + i)%slots_per_day][event.room_id] = {:event_id => event.event_id, :slots => slots - i}
          else
            table[event.day - 1 + (start_slot + i)/slots_per_day][(start_slot + i)%slots_per_day][event.room_id] = 0
          end
        else 
          table[event.day - 1][start_slot + i][event.room_id] = 0
        end
      end
    end
    table.each do | day_table | 
      while day_table.first && day_table.first.length == 1
        day_table.delete(day_table.first)
      end
      while day_table.last && day_table.last.length == 1
        day_table.delete(day_table.last)
      end
    end
    table
  end

  def select_tag( name, collection, key, value, selected, options = {}, with_empty = true )
    html = "<select name=\"#{ h(name) }\" id=\"#{h(name)}\""
    options.each do | html_key, html_value |
      html += " #{h(html_key)}=\"#{h(html_value)}\""
    end
    html += ">"
    html += '<option value=""></option>' if with_empty == true
    for coll in collection do
      if coll.kind_of?(Hash)
        html += "<option value=\"#{h(coll[key])}\" #{ coll[key] == selected ? 'selected="selected"': ''}>#{ h(coll[value])}</option>"
      elsif coll.kind_of?(String)
        html += "<option value=\"#{h(coll)}\" #{ coll == selected ? 'selected="selected"': ''}>#{h(coll)}</option>"
      else
        html += "<option value=\"#{ h(coll.send( key ))}\" #{ coll.send( key ) == selected ? 'selected="selected"' : ''}>#{ h( coll.send( value ) )}</option>"
      end
    end
    html += "</select>"
    html
  end

  def content_tabs_js( tabs_simple, environment = nil, with_show_all = true )
    html = '<script type="text/javascript">'
    html += 'var tab_name = new Array();'
    tabs_ui = []
    if environment
      tabs_ui = tabs_simple.collect do | tab_name | 
        "#{environment}::tab_#{tab_name.kind_of?(Hash) ? tab_name[:tag] : tab_name}"
      end
    end
    tabs_ui.push( 'tabs::show_all' ) if with_show_all == true
    tabs_local = Momomoto::View_ui_message.find({:language_id => @current_language_id, :tag => tabs_ui}) if environment || with_show_all
    tabs = []
    tabs_simple.each_with_index do | tab_name, index |
      tabs[index] = {}
      cur_tab_name = tab_name.kind_of?(Hash) ? tab_name[:tag] : tab_name
      tabs[index][:tag] = cur_tab_name
      tabs[index][:url] = tab_name.kind_of?(Hash) && tab_name[:url] ? tab_name[:url] : "javascript:switch_tab('#{cur_tab_name}');"
      tabs[index][:class] = "tab inactive"
      tabs[index][:accesskey] = index + 1
      if environment && tabs_local.find_by_id(:tag, "#{environment}::tab_#{tab_name}")
        tabs[index][:text] = tabs_local.name
      else
        tabs[index][:text] = tab_name.kind_of?(Hash) && tab_name[:text] ? tab_name[:text] : cur_tab_name
      end
      html += "tab_name[#{index}] = '#{cur_tab_name}';"
    end
    if with_show_all == true
      tabs_local.find_by_id( :tag, 'tabs::show_all')
      tabs.push({:tag=>'all',:url=>"javascript:switch_tab('all')", :class=>"tab inactive", :accesskey=>0, :text=> tabs_local.current_record ? tabs_local.name : 'show all'})
    end
    html += '</script>'
    
    content_tabs( tabs, html )
  end
  
  def content_tabs( tabs, html = '' )
    html += '<div id="tabs">'
    tabs.each_with_index do | tab, index |
      html += "<span>#{ link_to(h(tab[:text].to_s),  tab[:url].to_s, {:accesskey => ( tab[:accesskey] || ( index + 1 )), :class => tab[:class].to_s, :id => 'tab-'+tab[:tag].to_s})}</span>"
    end
    html += '</div>'
    html
  end

  def radio_button( name, value, checked, options = {} )
    radio_button_tag( name, value, value.to_s == checked.to_s, options )
  end

  def get_version()
    "0.2"
  end

  def get_revision()
    revision_file = '../../revision.txt'
    if File.exists?( revision_file ) && File.readable_real?( revision_file )
      rev = File.open( revision_file, 'r').gets.chomp 
    end
    rev = 2342 if rev.to_s == ''
    rev.to_s
  end

  def get_base_url()
    "https://" + @request.host + @request.env['REQUEST_URI'].gsub(/pentabarf.*/, '')
  end

end
