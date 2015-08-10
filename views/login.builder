xml.instruct! :xml, :version => '1.0'
xml.kdd do
  xml.state = 'Success'
  xml.duration = @duration
  xml.user do
    xml.name @user[:name]
    xml.status @user[:status]
    xml.lastLog = @user[:lastLog]
    xml.bonus = @user[:benefit]
  end
end
