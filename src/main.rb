require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/reloader'
require 'sinatra/json'

require 'viewpoint'

require 'nokogiri'

class Quiet < Sinatra::Base
  register Sinatra::ConfigFile

  set :root, File.join(File.dirname(__FILE__), '..')
  set :public_folder, File.join(root, 'public')

  config_file File.join(root, 'config.yml')

  configure :development do
    register Sinatra::Reloader
  end

  exch = Viewpoint::EWSClient.new(settings.endpoint, settings.username, settings.password)

  get '/' do
    redirect 'index.html'
  end

  get '/messages/inbox' do
    inbox = exch.get_folder :inbox
    messages = inbox.items.map do |m|
      {
        id: m.id,
        from: m.from.name,
        subject: m.subject,
        is_read: m.is_read?
      }
    end
    json messages: messages
  end

  get '/messages/:id/body' do
    message = exch.get_item params['id']
    if message.body_type == 'HTML'
      doc = Nokogiri::HTML(message.body)
      json body: doc.at('body').inner_html
    else
      json body: "<div class=\"text-content\">#{message.body}</div>"
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
