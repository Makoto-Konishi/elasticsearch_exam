(1..20).each do |i|
  Article.create(title: "記事#{i}", description: "記事内容#{i}")
end
