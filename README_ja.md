# Ignite
Ignite は SPA テンプレートです。以下の項目を含みます。

* Ansible: for VPS setup script
* Nginx: for Reverse Proxy, SSL offloading
* Certbot: for Automatic SSL certificate update
* Elm: for front-end framework
* golang/gin: for back-end framework
* MySQL: for RDB
* Redis: for KVS

## テスト済み環境

* 開発用PC
    * MacbookAir Core i5 RAM 8GB SSD 128GB: macOS Catalina
* VPS
    * Ubuntu 18.04 LTS

## 初期設定
### 1. Just fork this repository
GitHub の Fork ボタンを押してあなたのアカウントにフォークします。

### 2. Create New Repository and Clone Ignite
あなたが新しく作りたいアプリのリポジトリを新たに作成してください。
ここでは`sample-app`という名前をつけたとします。以下の一連のコマンドによってクローンされた Ignite が
`sample-app`のリポジトリに結びつきます。

```
$ git clone git@github.com:{your account}/ignite.git sample-app
$ cd sample-app
$ git remote set-url origin git@github.com:{your account}/sample-app.git
$ git push
```

### 3. Change Project Name
複数のアプリケーションを Ignite をベースにして作成し、同じ Docker ホストにデプロイしようとすると、
イメージ名やコンテナ名が衝突します。また、開発環境にコピーされる設定ファイル名も衝突します。
これを回避するため、Ignite はすべての`Makefile`の先頭に`APPNAME=ignite`という変数を持ち、
この変数を元にイメージ名やコンテナ名を決めています。

この変数を上書きするためのコマンドはプロジェクトルートの`Makefile`に記載されている`update_appname`コマンドです。
このコマンドはプロジェクトルートの`APPNAME`変数の値で、他のすべての`Makefile`先頭の`APPNAME`変数を上書きします。

つまり、プロジェクトルートの`APPNAME`変数を`APPNAME=sample-app`と変更したあとで以下のコマンドを実行してください。

```
$ make update_appname
```

念のため、もとの`Makefile`は同ディレクトリ内の`Makefile.bk`というファイルにバックアップされます。
安全のため`Makefile`の先頭以外では上書きを行わないので、すべての`Makefile`の先頭は必ず`APPNAME`変数の定義にするか、
そうでない場合は`Makefile`中で`APPNAME`変数を使用しないでください。

### 4. Copy Configuration Files to Your Development PC
Ignite はサーバー構築や MySQL の設定に用いる、GitHub には間違っても push されてはいけない情報、
たとえばサーバーの root パスワードなどを扱います。Ignite はこれらの情報が誤って push されるのを防ぐため、
重要な情報はリポジトリの外へ保管します。

デフォルトでの保管先は`~/config/${APPNAME}`です。以下のコマンドで確認することができます。

```
$ make true_inventory
```

Ignite のリポジトリに登録されているダミーの設定ファイルは、以下のコマンドを実行することで保管先にコピーされます。

```
$ make copy_inventory
```

コピーされた設定ファイルは脆弱なパスワードを含んでいるでの必ず確認して変更してください。

### 5. Communication Check to Your Server
あなたのサーバーと疎通が取れているか確認します。

以上で初期設定は完了です。

# 使用方法
### Build and Enter Ansible Client

```
$ cd ansible

# build image
$ make image

# create and enter the container
$ make shell
```

### Setup Server
After `$ make shell`, run following command in the ansible client container.

```
$ make root
$ make user
```
