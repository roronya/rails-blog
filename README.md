# README
コマンドは全て`docker-compose run app`をprefixに付ける。

## モデルの作り方

```
$ rails g model Post title:string body:text
```

でPostという名前でtitleとbodyを持つモデルが作られる。

## dbへの反映

```
$ rails db:migrate
```

## テストデータの作り方
### コンソールでやる
```
$ rails c
```

としてコンソールに入って

```
> q = Post.new(title: 'title 1', body: 'body 1')
> q.save
```

### ファイルでやる
app/db/seeds.rbでテストデータを作る

e.g.)

```ruby
5.times do |i|
  Post.create(title: "titile #{i}", body: "body #{i}")
end

```

```
$ rails db:seed
```


## データベースの入り方
```
$ rails db
```

## データベースのリセット

```
$ rails db:migrate:reset
```

## Controllerの作り方

```
$ rails g controller Posts
```

## ルーティングの設定
config/routes.rbに書く

e.g)

```ruby
resources :posts
```

## ルーティングの設定の確認

```shell
$ rails routes
```

## viewの作り方
/app/views/posts/以下にerbを置けば自動的に/app/controllers/posts_controller.rbからレンダリングされる。

Controllerでインスタンス変数(@posts)に束縛したものはerbの方で使える。

e.g.) postsの表示

```html
<% @posts.each do |post| %>
<li><%= post.title %></li>
<% end %>
```

## ルートパスを設定する

/にアクセスしたときに表示されるようにルーティングを設定する

e.g.) posts_controller.rbのindexを呼ぶ
```ruby
root 'posts#index'
```

## railsのルールのこと
Convention over Configuration(CoC)

Configに色々書き込むんじゃなくて、規約を決めてそれに乗っ取ってコーディングすることでコーディング量を減らす

## viewのアプリケーション全体のテンプレート

/app/views/layouts/application.html.erb

```ruby
<%= yield %>
```

と書いたところに書くviewファイルは埋め込まれる

## viewでリンクの貼り方
link_toヘルパーを使う
e.g.) postのtitleに詳細画面へのリンクを貼る場合

post GET    /posts/:id(.:format)      posts#show

```html
<%= link_to post.title, post_path(post.id) %>
<%= link_to post.title, post_path(post) %>
```

post_pathのところはrails routesで表示されるprefixに_pathを付ける。今回はpostのルーティングだからpost_path。

post.idと書いてもいいが、postと書いてもrailsがいい感じに解釈してくれる

コントローラの方ではこんな感じで書く

```ruby
def show
  @post = Post.find(params[:id])
end
```

params[:id]に束縛されるのは、routes.rbの方で:idがパラメタとして来るということが明示されているから。

## ActiveRecord
### 全部

```ruby
Post.all()
```

### 探す

```ruby
Post.find(id)
```

### 並び替え

```ruby
Post.all.order(created_at: 'desc')
```

### 保存

```ruby
@post = Post.new(params[:post])
@post.save
```

### エラー
saveに失敗した場合など、エラーを見る

```ruby
@post.save  # これでこけた場合 @post.error にエラーメッセージが束縛される
@post.error
```

コントローラで表示するにはこんな感じ

```ruby
render plain: @post.error.inspect
```

## 画像の配置
app/assets/imagesに画像を置いてerbからimageヘルパーを使う。

```html
<%= image_tag 'log.png', class: 'log' %>
```

## formの作り方
form_forヘルパーを使う

e.g.) postに対するフォームを作る

```html
<%= form_for :post, url: posts_path do |f| %>
<p>
    <%= f.text_field :title, placeholder: 'enter title' %>
</p>
<p>
    <%= f.text_area :body, placeholder: 'enter body text' %>
</p>
<% end %>
``` 

form_for(何に対するformか, url: actionのURL)

do |f| でformを作るためのヘルパーオブジェクトがfに束縛される

## formで送信されてきたデータをそのまま見る
コントローラで

```ruby
render plain: params[:post].inspect
```

## formで送られてきたデータの検証
StringParamsという

検証をしないとrailsに怒られる

```ruby
@post = Post.new(params.require(:post).permit(:title, :body))
```

requireでモデルを読み込んで、permitで:titleと:bodyを持つはずというチェックをしている。

## バリデーション
モデルに書く

```ruby
class Post <ApplicationRecord
  validates :title, presence: true, length: { minimum: 3}
  validates :body, presence: true
end
```

## リダイレクト

```ruby
redirect_to posts_path
```

## 改行を反映させる

simple_formatを使う

```html
<p><%= simple_format @post.body %></p>
```

## viewの共通部分をまとめる
パーシャルという仕組みを使う。_からファイル名を始める。

e.g.) formを括りだしてeditとnewで使う

_form.html.erb

```html
<%= form_for @post do |f| %>
    <p>
      <%= f.text_field :title, placeholder: 'enter title' %>
      <% if @post.errors.messages[:title].any? %>
          <span class="error"><%= @post.errors.messages[:title][0] %></span>
      <% end %>
    </p>
    <p>
      <%= f.text_area :body, placeholder: 'enter body text' %>
      <% if @post.errors.messages[:body].any? %>
          <span class="error"><%= @post.errors.messages[:body][0] %></span>
      <% end %>
    </p>
    <p>
      <%= f.submit %>
    </p>
<% end %>
```

new.html.erb

```html
<%= render 'form' %>
```

ボタンの名前とかURLのパラメタとかもrailsがいい感じにやってくれる。

## deleteメソッドでアクセスする

```html
<%= link_to '[x]', post_path(post), method: :delete, class: 'command', data: { confirm: 'Sure?' }%>
```

method:で:deleteとする

## 確認のpopupを出す

```html
<%= link_to '[x]', post_path(post), method: :delete, class: 'command', data: { confirm: 'Sure?' }%>
```

data:で{ confirm: 'Sure?' }とするとSure?というメッセージの確認ボタンが出る。

## Modelの関係

e.g.) postが複数のcommentを持つ

```ruby
class Comment < ApplicationRecord
  belongs_to :post
end 

class Post < ApplicationRecord
  has_many :comments
end

@post.comments  # これでpostが持つcommentにアクセスできる
```

pathの設定はroutes.rbに以下のように書くと生成できる。。

```ruby
resources :posts do
  resources :comments
end
```

生成されるpath

```bash
    post_comments GET    /posts/:post_id/comments(.:format)          comments#index
                  POST   /posts/:post_id/comments(.:format)          comments#create
 new_post_comment GET    /posts/:post_id/comments/new(.:format)      comments#new
edit_post_comment GET    /posts/:post_id/comments/:id/edit(.:format) comments#edit
     post_comment GET    /posts/:post_id/comments/:id(.:format)      comments#show
                  PATCH  /posts/:post_id/comments/:id(.:format)      comments#update
                  PUT    /posts/:post_id/comments/:id(.:format)      comments#update
                  DELETE /posts/:post_id/comments/:id(.:format)      comments#destroy

```

## ルーティングの設定を使うやつだけに絞る

e.g.)

```ruby
resources :posts do
    resources :comments, only: [:create, :destroy]
end
```

onlyで絞るとcreateとdestroyだけにできる。

## 削除時に関連するモデルのデータも削除する

モデルに以下のように書く

e.g.) Postを消したときに関連するcommentsも消す

```ruby
class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
end
```

dependentを設定することで実現できる。
