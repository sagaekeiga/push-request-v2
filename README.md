<!-- ---------------------------------------------------------------------------------->
## 環境構築（Mac版）

### 必要なソフトウェア一覧
以下のソフトウェアをインストールしてください。

`@TODO プロジェクトに依存するソフトウェアとインストール方法を追加してください`

| ソフトウェア | バージョン | 備考 |
|:-------------|:----------:|:-----|
| Ruby | 2.4.2 | [rbenv](https://github.com/rbenv/rbenv)経由でのインストールを推奨しています。 |
| Ruby on Rails | 5.1.6 | |
| PostgreSQL | 9.6.3 | |
| [Pow](http://pow.cx/) | 0.6.0 | サーバーを立ち上げるためのRackサーバー |

### Homebrewのインストール
```shell
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### rbenvのインストール
```shell
brew install rbenv ruby-build
# .bashrc等に追加で設定が必要です。詳細は公式サイトを参考にしてください。
```

### Rubyのインストール
`@TODO Rubyのバージョンは変動する可能性があります`
```shell
rbenv install 2.4.2
rbenv rehash
```

### 依存ライブラリ（gem）のインストール
以下のコマンドで依存ライブラリをインストールしてください。

```shell
cd your-project-directory
bundle install --path vendor/bundle
```

### 環境変数の設定
dotenv-rails経由で環境変数を読み込むようにしていますので、サンプルファイルをコピーして各自の設定をしてください。

```shell
cp dotenv.sample .env

# 各環境に合わせたAPIキー等の設定をする。詳細はdotenv.sampleを参照。
vim .env
```

### Yarnのインストール

```shell
brew install yarn
yarn install
```


### データベースの初期化
`@TODO プロジェクトに依存するrakeタスクを追加してください`

Yarnのインストールを行ってからmigrationを実行してください。

```shell
bundle exec rake db:create db:migrate db:seed
```

テストデータも一緒に作成する場合

```
bundle exec rails app:dev:reset
```

### モデルのannotate
[annotate](https://github.com/ctran/annotate_models) を使ってmodel等にschema情報を保存できます
```
bundle exec rails g annotate:install
```

### プロセス立ち上げ
```shell
bundle exec foreman start -f Procfile.dev
```

### Powとの連携
domain制約をつけているので、以下でpowと連携

```shell
echo '3001' > ~/.pow/push-request-v2
```

3001が競合する場合は適宜変更してください（その際、Procfile.devでrails serverで指定している引数も変更してください）

Powの.devドメインがchomeだと弾かれるので.testドメインを使用してください。
[参考](https://rcmdnk.com/blog/2017/12/27/blog-octopress/ "リンクのタイトル")

### 管理画面
セットアップが完了した時点で[http://admin.push-request.test/](http://admin.push-request.test/ "http://admin.push-request.test/")にアクセスして

```
email : admin1@example.com
password : hogehoge
```

で管理画面にログイン可能です。

<!-- ---------------------------------------------------------------------------------->
## テスト方法
`@TODO サービスのテスト手順を記載してください。`
```shell
bundle exec rspec
```


<!-- ---------------------------------------------------------------------------------->
## リリース手順

PRをMerge後、staging環境に自動デプロイされます。
staging環境での動作確認・productionへのpromoteは寒河江が行います。


<!-- ---------------------------------------------------------------------------------->
## 注意事項
`@TODO プロジェクトを進めるにあたっての注意事項を記載してください。`

### ● 静的解析

CircleCIにrails_best_practices、brakeman、bullet、rubocopを設定しています。
今は、コメントアウトをしており使用していませんが最低限のバグ潰し、機能の追加が終了しましたら稼働させて行く予定です。

### ● JavaScript

![ES6](https://static.amido.com/wp-content/uploads/2016/10/24155219/ES6.png "サンプル")

Rails 5.1 以降で導入された webpacker を利用して、ES6 で記述します。
`/app/javascript/packs`にファイルを作成し、コーディングを行ってください。

### ● コメント


クラス単位でのコメントは最小限に（そもそもクラス名を見てその役割が分からないのはおかしいので）とどめる形で構いません。

関数単位でのコメントは

* その関数が行っていること
* 引数の説明
* 戻り値の説明
* その他補足事項
を記述するようにしてください（以下の例を参照）。

```ruby
#
# PushRequestの業務に関する処理を記述する
#
class PushrequestCorporation

  #
  # 社員に給料を支払う
  #
  # 何の変哲もないアクションです。
  #
  # @TODO 通貨が変わった場合はどうする？
  #
  # @param [User] user 給料を支払うユーザー
  # @param [Integer] price 支払い金額
  #
  # @return [Boolean] 支払い処理に成功したらtrue、失敗したらfalse
  #
  def paySalary(user, price)
    # ...
  end
end
```

### ● ドキュメンテーションについて

設定や備考録等、対象プロジェクトに関するドキュメントは GitHub の Wiki にまとめてください。

無理やり 1 ページに納める必要はないので、Home ページからリンクを貼る形で機能/項目単位でページを作成して問題ありません。

### ● ISSUE・PULLREQUESTの書き方

テンプレートを埋め込んであるのでその見出しにしたがって内容を書いてください。
全て書く必要はなく、必要な分だけ書いてください。
過去のISSUEやPULLREQUESTを参考にしてください。
