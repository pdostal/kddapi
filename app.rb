helpers do
end

get '/' do
  erb :index
end

get '/search' do
  @books = Array.new

  clnt = HTTPClient.new
  # clnt.debug_dev = STDOUT
  clnt.set_cookie_store 'cookie.dat'

  _now = Time.now.to_f

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
  clnt.save_cookie_store
  puts Time.new().strftime("%H:%M:%S:%L")+" => End GET /?page=search"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Parsing"
  doc = Nokogiri::HTML res.content
  itms = doc.css('td')

  _end = Time.now.to_f
  @duration = _end - _now

  for i in 0..(itms.count/14)-1
    name = itms[i*14].text
    id = itms[i*14].css('a')[0]['href'].sub(/\?page=doc-detail&id=/, '')
    url = "http://kdd.cz/file.php?id=#{id}"
    author = Sanitize.clean itms[(i*14)+3].text.strip
    description = Sanitize.clean itms[(i*14)+4].text.strip
    subject = Sanitize.clean itms[(i*14)+7].text.strip
    publisher = Sanitize.clean itms[(i*14)+8].text.strip
    year = Sanitize.clean itms[(i*14)+9].text.strip
    type = Sanitize.clean itms[(i*14)+10].text.strip
    state = Sanitize.clean itms[(i*14)+11].text.strip
    @books << { name: name, id: id, url: url,
    author: author, description: description, subject: subject,
    publisher: publisher, year: year, type: type, state: state }
  end
  puts Time.new().strftime("%H:%M:%S:%L")+" => Parsed"

  builder :search
end
