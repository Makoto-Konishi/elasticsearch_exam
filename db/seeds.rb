(1..30).each do |i|
  Author.create(id: i, name: "著者#{i}")
  Publisher.create(id: i, name: "出版社#{i}")
  Category.create(id: i, name: "カテゴリー#{i}")
  Article.create(
    id: i,
    title: "記事#{i}",
    description: "記事内容#{i}",
    author_id: rand(1..30),
    publisher_id: rand(1..30),
    category_id: rand(1..30)
  )
end
