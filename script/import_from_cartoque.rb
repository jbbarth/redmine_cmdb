#!/usr/bin/env ruby

#
# This is a sample script for feeding the redmine_cmdb plugin from a Cartoque CMDB
#
# It will help you connect a Redmine instance to a Cartoque instance, but be sure the
# strategy presented here is not specific to Cartoque at all, it could work with any
# CMDB with an API, or even with your preferred ETL tool. If you want to stick with
# this script but don't use Cartoque, you'll have to replace the first part where I
# define how configuration items can be listed in the CMDB product, and mappings with
# redmine_cmdb fields.
#
# For the sake of simplicity, all parameters are defined as environment variables here.
# Again, choose what works for you. So you'll need these variables:
#   * REDMINE_URL: the url to reach your redmine instance ; REST API must be enabled
#   * REDMINE_TOKEN : a token you'll use to connect to Redmine ; the user must be admin
#                     so that he can insert and delete configuration items
#   * CARTOQUE_URL : the url of your cartoque instance
#   * CARTOQUE_TOKEN : the token of the chosen user in your cartoque instance ; he will
#                      only read configuration_items through cartoque's REST API
#   * CI_TYPES : the CI types you want to synchronize ; defaults to "Application,Server"
#

require 'rubygems'
require 'httparty'
require 'pp'

# ----- modify this class with your own CMDB mappings -----
class CMDBExporter
  include HTTParty
  base_uri ENV['CARTOQUE_URL']
  default_params api_token: ENV['CARTOQUE_TOKEN']
  format :json

  class << self
    def find_all_configuration_items
      ary = []
      configuration_item_types.each do |type|
        plural = "#{type.downcase}s"
        get("/#{plural}").parsed_response["#{plural}"].map do |item|
          ary << { name: item['name'],
                  item_type: type,
                  url: url_for(plural, item),
                  cmdb_identifier: item['id'] }
        end
      end
      ary
    end

    def url_for(plural, item)
      @cmdb_url ||= URI.parse(base_uri)
      @cmdb_url.merge("/#{plural}/#{item['slug'] || item['id']}").to_s
    end

    def configuration_item_types
      (ENV['CI_TYPES'] || "Application,Server").strip.split(",")
    end
  end
end
# ----- end of CMDB-related things -----

class RedmineCMDBImporter
  include HTTParty
  base_uri ENV['REDMINE_URL']
  default_params key: ENV['REDMINE_TOKEN']
  format :json

  class << self
    def find_all_configuration_items
      res = get('/configuration_items.json')
      raise "Unable to connect to Redmine (invalid credentials)" if res.code == 401
      res.parsed_response['configuration_items'].map do |hsh|
        hsh.keys.each do |key|
          #http://apidock.com/rails/Hash/symbolize_keys!
          hsh[(key.to_sym rescue key) || key] = hsh.delete(key)
        end
        hsh
      end.select do |hsh|
        configuration_item_types.include?(hsh[:item_type])
      end
    end

    def remove_item(id)
      delete("/configuration_items/#{id}")
    end

    def add_item(attrs)
      res = post('/configuration_items.json', body: {configuration_item: attrs})
      puts "  errors importing #{attrs.inspect}: #{res.parsed_response['errors'].join(', ')}" if res.code == 422
    end

    def update_item(id, attrs)
      res = put("/configuration_items/#{id}.json", body: {configuration_item: attrs})
      puts "  errors importing #{attrs.inspect}: #{res.parsed_response['errors'].join(', ')}" if res.code == 422
    end

    def configuration_item_types
      (ENV['CI_TYPES'] || "Application,Server").strip.split(",")
    end
  end
end

# STEP 1 : List all configuration items in the CMDB
# =================================================
cmdb_items = CMDBExporter.find_all_configuration_items
puts "Found #{cmdb_items.count} items in the CMDB:"
types = cmdb_items.map{|i| i[:item_type]}
types.uniq.sort.each do |type|
  puts "  - #{types.count(type)} #{type}"
end

redmine_items = RedmineCMDBImporter.find_all_configuration_items
puts "Found #{redmine_items.count} items in Redmine:"
types = redmine_items.map{|i| i[:item_type]}
types.uniq.sort.each do |type|
  puts "  - #{types.count(type)} #{type}"
end

# STEP 2 : Delete configuration items which don't exist anymore
# =============================================================
cmdb_identifiers = cmdb_items.map{|i|i[:cmdb_identifier]}
redmine_items.each do |item|
  next if cmdb_identifiers.include?(item[:cmdb_identifier])
  next if ! item[:active]
  puts "Deleting #{item[:item_type]} #{item[:name]} because it doesn't exist anymore in the CMDB"
  RedmineCMDBImporter.remove_item(item[:id])
end

# STEP 3 : Add new configuration items
# ====================================
redmine_identifiers = redmine_items.map{|i|i[:cmdb_identifier]}
cmdb_items.each do |item|
  if redmine_identifiers.include?(item[:cmdb_identifier])
    redmine_item = redmine_items.detect{|i|i[:cmdb_identifier] == item[:cmdb_identifier]}
    raise "Unable to find redmine item with cmdb_identifier=#{item[:cmdb_identifier]} but it shouldn't happen here..." if redmine_item.nil?
    if item.keys.detect{|key| key != :id && key != :status && item[key] != redmine_item[key]}
      puts "Updating #{item[:item_type]} #{item[:name]}"
      RedmineCMDBImporter.update_item(redmine_item[:id], item)
    end
  else
    puts "Adding #{item[:item_type]} #{item[:name]} to Redmine"
    RedmineCMDBImporter.add_item(item)
  end
end
