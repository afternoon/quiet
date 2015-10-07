require 'viewpoint'
require 'yaml'

CONFIG_FILE = 'config.yml'
SETTINGS = YAML.load_file CONFIG_FILE
CONN = Viewpoint::EWSClient.new SETTINGS['endpoint'], SETTINGS['username'], SETTINGS['password']

module Quiet
  def Quiet.settings
    SETTINGS
  end

  def Quiet.conn
    CONN
  end
end
