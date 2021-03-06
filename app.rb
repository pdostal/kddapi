Typhoeus::Config.verbose = true

get '/' do
  erb :index
end

get '/login' do
  @user = Array.new

  cookiefile = "tmp/cookie_#{params[:user]}.dat"
  duration_now = Time.now.to_f

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run POST /"
  res = Typhoeus::Request.new(
    'http://kdd.cz/index.php',
    cookiefile: cookiefile,
    cookiejar: cookiefile,
    method: :post,
    params: {
      'login[username]': params[:user],
      'login[password]': params[:pass]
    }
  ).run
  puts Time.new().strftime("%H:%M:%S:%L")+" => End POST /"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run GET /?page=user"
  res = Typhoeus::Request.new(
    'http://kdd.cz/index.php',
    cookiefile: cookiefile,
    cookiejar: cookiefile,
    method: :get,
    params: {
      'page': 'user',
      'lang': 'en'
    }
  ).run
  puts Time.new().strftime("%H:%M:%S:%L")+" => End GET /?page=user"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Parsing"
  doc = Nokogiri::HTML res.body
  itms = doc.css('li')

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

  duration_end = Time.now.to_f
  @duration = duration_end - duration_now

   builder :login
end

get '/download' do
  cookiefile = "tmp/cookie_#{params[:user]}.dat"
  duration_now = Time.now.to_f

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run POST /"
  res = Typhoeus::Request.new(
    'http://kdd.cz/index.php',
    cookiefile: cookiefile,
    cookiejar: cookiefile,
    method: :post,
    params: {
      'login[username]': params[:user],
      'login[password]': params[:pass]
    }
  ).run
  puts Time.new().strftime("%H:%M:%S:%L")+" => End POST /"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run GET /?page=user"
  res = Typhoeus::Request.new(
    'http://kdd.cz/index.php',
    cookiefile: cookiefile,
    cookiejar: cookiefile,
    method: :get,
    params: {
      'page': 'user',
      'lang': 'en'
    }
  ).run
  puts Time.new().strftime("%H:%M:%S:%L")+" => End GET /?page=user"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run GET /?file=12345"
  res = Typhoeus::Request.new(
    'http://kdd.cz/file.php',
    cookiefile: cookiefile,
    cookiejar: cookiefile,
    method: :get,
    params: {
      'id': params[:id]
    }
  ).run

  name = File.join "tmp/#{params[:id]}.zip"
  file = File.new name, 'w'
  file.write res.body
  file.close

  puts Time.new().strftime("%H:%M:%S:%L")+" => End GET /?file=12345"

  send_file name, disposition: 'attachment', filename: File.basename(name)

  duration_end = Time.now.to_f
  @duration = duration_end - duration_now
end

get '/search' do
  @books = Array.new

  cookiefile = "tmp/cookie_#{params[:user]}.dat"
  duration_now = Time.now.to_f

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run POST /"
  res = Typhoeus::Request.new(
    'http://kdd.cz/index.php',
    cookiefile: cookiefile,
    cookiejar: cookiefile,
    method: :post,
    params: {
      'login[username]': params[:user],
      'login[password]': params[:pass]
    }
  ).run
  puts Time.new().strftime("%H:%M:%S:%L")+" => End POST /"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run GET /?page=user"
  res = Typhoeus::Request.new(
    'http://kdd.cz/index.php',
    cookiefile: cookiefile,
    cookiejar: cookiefile,
    method: :get,
    params: {
      'page': 'user',
      'lang': 'en'
    }
  ).run
  puts Time.new().strftime("%H:%M:%S:%L")+" => End GET /?page=user"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Run GET /?page=search"
  res = Typhoeus::Request.new(
    'http://kdd.cz/index.php',
    cookiefile: cookiefile,
    cookiejar: cookiefile,
    method: :get,
    params: {
      'page': 'search',
      'akce': 'Search',
      'paging': params[:page],
      'base-search[column]': params[:kind],
      'base-search[language]': 'all',
      'base-search[count-per-page]': '99',
      'base-search[string]': params[:query]
    }
  ).run
  puts Time.new().strftime("%H:%M:%S:%L")+" => End GET /?page=search"

  puts Time.new().strftime("%H:%M:%S:%L")+" => Parsing"
  doc = Nokogiri::HTML res.body
  info =  doc.css('p')
  itms = doc.css('td')

  for i in 0..(info.count)-1
    string = Sanitize.clean info[i].text.split.join(' ')
    if string =~ /Total number of found results/
      @count = string.gsub(/.*Total number of found results ([0-9]*).*/, '\1').to_i
    end
  end
  if !@count.is_a? Numeric
    @count = 0
  end

  @page = params[:page].to_i
  @pages = (@count.to_f/99.to_f).ceil.to_i

  if @count <= 99
    @shown = @count
  elsif @page == @pages
    @shown = @count - ( @page - 1 ) * 99
  else
    @shown = 99
  end

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
  
  duration_end = Time.now.to_f
  @duration = duration_end - duration_now

  puts Time.new().strftime("%H:%M:%S:%L")+" => Parsed"

  builder :search
end
