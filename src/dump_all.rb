require 'viewpoint'
require 'yaml'
require 'json'
require_relative 'conn'

OUTPUT_DIR = 'output'

def all_folders
  Quiet.conn().folders root: :root, traversal: :deep, folder_type: :mail
end

def inbox
  Quiet.conn().get_folder :inbox
end

def mailbox_user(mu)
  {name: mu.name, email: mu.email_address} unless mu.nil?
end

def write_json_file(filename, data)
  FileUtils.mkdir_p File.dirname(filename)
  File.open(filename, 'w') do |output_file|
    output_file.write(data.to_json)
  end
end

def dump_item(folder, item)
  message_data = {
    folder: folder.display_name,
    subject: item.subject,
    id: item.id,
    internet_message_id: item.internet_message_id,
    internet_message_headers: item.internet_message_headers,
    date_time_sent: item.date_time_sent,
    sender: mailbox_user(item.sender),
    to_recipients: item.to_recipients.map { |mu| mailbox_user(mu) },
    cc_recipients: item.cc_recipients.map { |mu| mailbox_user(mu) },
    conversation_id: item.conversation_id,
    body: item.body,
    attachments_count: item.attachments.count,
    is_read: item.is_read?
  }
  filename = File.join OUTPUT_DIR, folder.display_name, item.id.gsub('/', '_') + '.json'
  write_json_file(filename, message_data)
end

def dump_folder(folder)
  folder.items.each { |i| dump_item(folder, i) }
end

def sync_folder(folder)
  puts "====> Syncing #{folder.display_name}"
  until folder.synced?
    sync_changes = folder.sync_items! nil, 512, false, base_shape: 'AllProperties'
    if sync_changes.has_key?(:create)
      puts "====> #{sync_changes[:create].count} items to create"
      sync_changes[:create].each { |i| dump_item(folder, i) }
    end
  end
end

all_folders().each { |f| sync_folder(f) }
# dump_folder(inbox())
# sync_folder(inbox())
