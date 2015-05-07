require 'net/http'
require 'uri'
require 'json'
require 'httparty'
require 'haml'
require 'pp'
require 'padrino-helpers'
get "/" do
  begin
    response = HTTParty.post("http://shell.storm.pm:8079/api/query",{
      :body => "select distinct Metadata/Location",
      :headers => { 'Content-Type' => 'text/plain', 'Accept' => '*/*' }
    })
    json = JSON.parse(response.body)
  rescue Exception => e
  end
  locations = []
  json.each do |location|
    if location.class.name == ''.class.name
      locations.push(location)
    end
  end
  erb :index, :locals => {:locations => locations}
end

get '/api/locations' do
  begin
    response = HTTParty.post("http://shell.storm.pm:8079/api/query",{
      :body => "select distinct Metadata/Location",
      :headers => { 'Content-Type' => 'text/plain', 'Accept' => '*/*' }
    })
    json = JSON.parse(response.body)
  rescue Exception => e
  end
  locations = []
  json.each do |location|
    if location.class.name == ''.class.name
      locations.push(location)
    end
  end
  locations.to_json
end
get "/api/location/:name/sources" do
  response = HTTParty.post("http://shell.storm.pm:8079/api/query",{
    :body => "select * where Metadata/Location='#{params['name']}'",
    #:body => "select data before now where Metadata/SourceName='Super Tommy'",
    :headers => { 'Content-Type' => 'text/plain', 'Accept' => '*/*' }
  })
  json = JSON.parse(response.body)
  sources = []
  json.each do |obj|
    if obj['Metadata']['SourceName']
      sources.push(obj['Metadata']['SourceName'])
    end
  end
  sources.uniq!
  results = {}
  readings = []
  sources.each do |source_name|
    response = HTTParty.post("http://shell.storm.pm:8079/api/query",{
      :body => "select data in (now -10h, now) where Metadata/SourceName='#{source_name}'",
      :headers => { 'Content-Type' => 'text/plain', 'Accept' => '*/*' }
    })
    json = JSON.parse(response.body)
    readings = []
    type = 0
    json.each do |reading|
      if reading['Readings'] != nil and reading['Readings'][0] != nil and reading['Readings'][0][1] 
        if reading['Readings'][0] != nil and reading['Readings'][0][1] != nil and reading['Readings'][0][1][1] != nil
          type = reading['Readings'][0][1][1].to_i
        end
        readings.push([reading['Readings'][0][0], reading['Readings'][0][1][0].to_i])
      end
    end
    results[source_name] = { 'type' => type, 'Readings' => readings }
  end
  erb :location, :locals => {:sensors => results}
end
get "/location/:name" do
  response = HTTParty.post("http://shell.storm.pm:8079/api/query",{
    :body => "select * where Metadata/Location='#{params['name']}'",
    :headers => { 'Content-Type' => 'text/plain', 'Accept' => '*/*' }
  })
  json = JSON.parse(response.body)
  sources = []
  json.each do |obj|
    if obj['Metadata']['SourceName']
      sources.push(obj['Metadata']['SourceName'])
    end
  end
  sources.uniq!
  results = {}
  readings = []
  sources.each do |source_name|
    response = HTTParty.post("http://shell.storm.pm:8079/api/query",{
      :body => "select data in (now -5m, now) where Metadata/SourceName='#{source_name}'",
      :headers => { 'Content-Type' => 'text/plain', 'Accept' => '*/*' }
    })
    json = JSON.parse(response.body)
    type = 0
    data =[]
    json.each do |source_info|
      readings = source_info['Readings']
      if readings and !readings.empty?
        type = readings.last[1][1].to_i
        readings.each do |reading|
          data.push([reading[0], reading[1][0].to_i])
        end
      end
    end
    results[source_name] = {'type'=>type, 'Readings'=> data}
    results[source_name]['Readings'].reverse!
  end
  erb :location, :locals => {:sensors => results}
 
end

get '/smapquery' do
  response = HTTParty.post("http://shell.storm.pm:8079/api/query",{
      :body => "select data in (now -5m, now) where Metadata/SourceName='Jewels'",
      :headers => { 'Content-Type' => 'text/plain', 'Accept' => '*/*' }
  })
  json = JSON.parse(response.body)
  json.to_json
end
