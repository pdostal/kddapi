xml.instruct! :xml, :version => '1.0'
xml.kdd do
  xml.result 'Success'
  xml.count @books.count
  xml.duration @duration
  @books.each do |book|
    xml.book do
      xml.name book[:name]
      xml.id book[:id]
      xml.url book[:url]
      book[:authors].each do |author|
        if !Sanitize.clean(author).strip.empty?
          xml.author Sanitize.clean(author).strip
        end
      end
      xml.description book[:description]
      xml.subject book[:subject]
      xml.publisher book[:publisher]
      xml.year book[:year]
      xml.type book[:type]
      xml.state book[:state]
    end
  end
end
