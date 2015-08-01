xml.instruct! :xml, :version => '1.0'
xml.kdd do
  xml.state = 'Success'
  xml.count = @books.count
  xml.duration = @duration
  @books.each do |book|
    xml.book do
      xml.name book[:name]
      xml.id book[:id]
      xml.url = book[:url]
      xml.author = book[:author]
      xml.description = book[:description]
      xml.subject = book[:subject]
      xml.publisher = book[:publisher]
      xml.year = book[:year]
      xml.type = book[:type]
      xml.state = book[:state]
    end
  end
end
