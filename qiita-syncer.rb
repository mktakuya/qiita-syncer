require 'qiita'
require 'tilt'

class QiitaSyncer
  def initialize
    @qiita_client = Qiita::Client.new
    @config = YAML.load_file('./config.yml')
  end

  def fetch_items
    response = @qiita_client.list_user_items(@config['qiita_id'])

    items = []
    response.body.each { |item| items.push(item) }
    return items
  end

  def generate_entry_page(item)
    template = Tilt.new("#{__dir__}/templates/entry.erb")
    html = template.render(
      Object.new, title: item['title'], url: item['url'], body: item['body']
    )
    File.write(@config['entries_path'] + "/#{item['id']}.html", html)
  end

  def generate_index_page(items)
    template = Tilt.new("#{__dir__}/templates/index.erb")
    html = template.render(Object.new, items: items)
    File.write(@config['entries_path'] + "/index.html", html)
  end
end

if __FILE__ == $0
  qiita_syncer = QiitaSyncer.new
  items = qiita_syncer.fetch_items
  items.each do |item|
    qiita_syncer.generate_entry_page(item)
  end
  qiita_syncer.generate_index_page(items)
end

