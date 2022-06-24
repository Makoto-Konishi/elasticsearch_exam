(21..30).each do |i|
  Article.create(title: "記事#{i}", description: "記事内容#{i}", user_id: 1)
end
