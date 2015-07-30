helpers do
end

get '/' do
  erb :index
end

get '/search_all' do
  # clnt = HTTPClient.new
  #
  # uri = 'http://kdd.cz/'
  # query = {
  #   'login[username]' => params[:u],
  #   'login[password]' => params[:p]
  # }
  # res = clnt.post(uri, query)
  #
  # uri = 'http://kdd.cz/index.php'
  # query = {
  #   'page' => 'user',
  #   'lang' => 'en'
  # }
  # res = clnt.get(uri, query)
  #
  # uri = 'http://kdd.cz/index.php'
  # query = {
  #   'page' => 'search',
  #   'akce' => 'Search',
  #   'base-search[column]' => 'vse',
  #   'base-search[language]' => 'all',
  #   'base-search[count-per-page]' => '99',
  #   'base-search[string]' => params[:q]
  # }
  # res = clnt.get(uri, query)
  #
  # doc = Nokogiri::HTML res.content
  # itms = doc.css('td')

  @books = Array.new
  # for i in 0..(itms.count/14)-1
  #   name = itms[i*14].text
  #   id = itms[i*14].css('a')[0]['href'].sub(/\?page=doc-detail&id=/, '')
  #   url = "http://kdd.cz/file.php?id=#{id}"
  #   author = Sanitize.clean itms[(i*14)+3].text.strip
  #   description = Sanitize.clean itms[(i*14)+4].text.strip
  #   subject = Sanitize.clean itms[(i*14)+7].text.strip
  #   publisher = Sanitize.clean itms[(i*14)+8].text.strip
  #   year = Sanitize.clean itms[(i*14)+9].text.strip
  #   type = Sanitize.clean itms[(i*14)+10].text.strip
  #   state = Sanitize.clean itms[(i*14)+11].text.strip
  #   @books << { name: name, id: id, url: url,
  #   author: author, description: description, subject: subject,
  #   publisher: publisher, year: year, type: type, state: state }
  # end

  builder :search_all
end
