clnt = HTTPClient.new
# clnt.set_cookie_store '/home/vagrant/www/kddapi/tmp/cookies.dat'

get '/' do
  erb :index
end

get '/login' do
  @user = Array.new

  duration_now = Time.now.to_f

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run POST /"
  uri = 'http://kdd.cz/'
  query = {
    'login[username]' => params[:user],
    'login[password]' => params[:pass]
  }
  res = clnt.post(uri, query)
  puts Time.new().strftime("%H:%M:%S:%L")+" => End POST /"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run GET /?page=user"
  uri = 'http://kdd.cz/'
  query = {
    'page' => 'user',
    'lang' => 'en'
  }
  res = clnt.get(uri, query)
  puts Time.new().strftime("%H:%M:%S:%L")+" => End GET /?page=user"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Parsing"
  doc = Nokogiri::HTML res.content
  itms = doc.css('li')

  duration_end = Time.now.to_f
  @duration = duration_end - duration_now

  for i in 0..(itms.count)-1
    if itms[i].text.strip =~ /Logged: /
      name = itms[i].text.strip.gsub(/Logged: (.+)/, '\1')
    end
    if itms[i].text.strip =~ /Account status: /
      status = itms[i].text.strip.gsub(/Account status: ([0-9]+) Credits/, '\1')
    end
    if itms[i].text.strip =~ /Your last login date: /
      lastLog = itms[i].text.strip.gsub(/Your last login date: ([0-9]+)/, '\1')
    end
    if itms[i].text.strip =~ /Your benefit account status: /
      benefit = itms[i].text.strip.gsub(/Your benefit account status: ([0-9]+) Credits/, '\1')
    end
  end
  @user = { name: name, status: status, lastLog: lastLog, benefit: benefit }
  puts Time.new().strftime("%H:%M:%S:%L")+" => Parsed"

  builder :login
end

get '/download' do
  duration_now = Time.now.to_f

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run POST /"
  uri = 'http://kdd.cz/'
  query = {
    'login[username]' => params[:user],
    'login[password]' => params[:pass]
  }
  res = clnt.post(uri, query)
  puts res.cookies
  puts Time.new().strftime("%H:%M:%S:%L")+" => End POST /"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run GET /?page=user"
  uri = 'http://kdd.cz/'
  query = {
    'page' => 'user',
    'lang' => 'en'
  }
  res = clnt.get(uri, query)
  puts res.cookies
  puts Time.new().strftime("%H:%M:%S:%L")+" => End GET /?page=user"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run GET /?file=12345"
  uri = "http://kdd.cz/file.php"
  query = {
    'id' => params[:id]
  }
  res = clnt.get(uri, query)

  name = File.join '/home/vagrant/www/kddapi/tmp', params[:id]+'.zip'
  file = File.new name, 'w+'
  file.write res.content
  file.close

  puts Time.new().strftime("%H:%M:%S:%L")+" => End GET /?file=12345"

  send_file name, disposition: 'attachment', filename: File.basename(name)

  duration_end = Time.now.to_f
  @duration = duration_end - duration_now
end

get '/search' do
  @books = Array.new

  duration_now = Time.now.to_f

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run POST /"
  uri = 'http://kdd.cz/'
  query = {
    'login[username]' => params[:user],
    'login[password]' => params[:pass]
  }
  res = clnt.post(uri, query)
  puts Time.new().strftime("%H:%M:%S:%L")+" => End POST /"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run GET /?page=user"
  uri = 'http://kdd.cz/'
  query = {
    'page' => 'user',
    'lang' => 'en'
  }
  res = clnt.get(uri, query)
  puts Time.new().strftime("%H:%M:%S:%L")+" => End GET /?page=user"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run GET /?page=search"
  uri = 'http://kdd.cz/index.php'
  query = {
    'page' => 'search',
    'akce' => 'Search',
    'base-search[column]' => params[:kind],
    'base-search[language]' => 'all',
    'base-search[count-per-page]' => '99',
    'base-search[string]' => params[:query]
  }
  res = clnt.get(uri, query)
  puts Time.new().strftime("%H:%M:%S:%L")+" => End GET /?page=search"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Parsing"
  doc = Nokogiri::HTML res.content
  itms = doc.css('td')

  duration_end = Time.now.to_f
  @duration = duration_end - duration_now

  for i in 0..(itms.count/14)-1
    name = itms[i*14].text
    id = itms[i*14].css('a')[0]['href'].sub(/\?page=doc-detail&id=/, '')
    url = "http://kdd.cz/file.php?id=#{id}"
    author = itms[(i*14)+3].to_s.split("<br>")
    description = Sanitize.clean itms[(i*14)+4].text.strip
    subject = Sanitize.clean itms[(i*14)+7].text.strip
    publisher = Sanitize.clean itms[(i*14)+8].text.strip
    year = Sanitize.clean itms[(i*14)+9].text.strip
    type = Sanitize.clean itms[(i*14)+10].text.strip
    state = Sanitize.clean itms[(i*14)+11].text.strip
    @books << { name: name, id: id, url: url,
    authors: author, description: description, subject: subject,
    publisher: publisher, year: year, type: type, state: state }
  end
  puts Time.new().strftime("%H:%M:%S:%L")+" => Parsed"

  builder :search
end

# clnt.save_cookie_store
