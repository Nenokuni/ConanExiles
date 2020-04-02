# 概要

ConanExiles Dedicated server を自動で建てる Docker コンテナ。

# コンテナの構築から起動まで

必要要件
| アプリケーション | バージョン                |
| :--------------- | :------------------------ |
| docker           | `19.03.8`                 |
| docker-compose   | `1.25.4`                  |

リポジトリをクローン。
```
git clone https://github.com/sevenspice/ConanExiles.git
```

ディレクトリ移動。
```
cd ConanExiles
```

docker-compose.ymlの作成。
```
cp docker-compose.origin.yml docker-compose.yml
```

docker-compose.yml の編集。
```
vi docker-compose.yml
```
* environment の箇所を適切に編集すること。

コンテナの構築・生成・起動。
```
docker-compose up -d --build
```

# ゲームサーバー起動方法

コンテナ起動時に自動でゲームサーバーが起動しないように設定している。
* 設定の変更等を起動前に手動で行う場合を想定している。

コンテナにログイン。
```
docker exec -it conan /bin/bash
```

サーバー起動。
```
/start.sh
```

起動を確認する。
```
screen -ls
screen -r conan
```

デタッチする。
```
ctl-A ctl-d
```

ログアウト。
```
exit
```

## コンテナにログインせずに起動する

```
docker exec -it conan sh -c "exec >/dev/tty 2>/dev/tty </dev/tty && /start.sh"
```

# ゲームデータの保存先

ゲームサーバーデータ。
```
/conan/server/ConanSandbox/Saved
```

キャッシュデータ。
```
/root
```

ボリューム。
```
conan_exiles
conan_exiles-wine
```
* ゲームデータをバックアップするのであれば上記ボリュームをバックアップすればよい。

# ゲームサーバー通常再起動手順

* サーバーメッセージや管理者パスワード・サーバー設定を変更した場合はこの手順で再起動すると反映される。

コンテナ停止。
```
docker-compose down
```

コンテナ起動。
```
docker-compose up -d
```

コンテナにログイン。
```
docker exec -it conan /bin/bash
```

サーバー起動。
```
/start.sh
```

起動を確認する。
```
screen -ls
screen -r conan
```

デタッチする。
```
ctl-A ctl-d
```

ログアウト。
```
exit
```

# ゲームサーバーアップデート手順

* ゲームサーバーのアップデートだけならばイメージを作り直す必要はない。
* 下記手順でゲームサーバーのアップデートは行える。

コンテナにログイン。
```
docker exec -it conan /bin/bash
```

サーバーを停止。
```
/kill.sh
```

アップデート。
```
/update.sh
```

ログアウト。
```
exit
```

# コンテナフルアップデート手順

* コンテナそのものに変更を加えた場合はイメージを作り直す必要がある。
* ボリュームデータのバックアップとリストアを行わなければ以前の状態を保持できないため注意すること。

ボリュームデータのバックアップ。
```
docker run --rm --volumes-from conan -v conan-saved:/backup busybox tar cvf /backup/backup.tar /conan/server/ConanSandbox/Saved
docker run --rm --volumes-from conan -v conan-saved-wine:/backup busybox tar cvf /backup/backup.tar /root
```

コンテナとボリュームの削除。
```
docker-compose down -v
```

イメージを削除する。
```
docker rmi conan:latest
```

イメージの再構築からコンテナの構築・起動。
```
docker-compose up -d --build
```

ボリュームデータのリストア。
```
docker run --rm --volumes-from conan -v conan-saved:/backup busybox tar xvf /backup/backup.tar
docker run --rm --volumes-from conan -v conan-saved-wine:/backup busybox tar xvf /backup/backup.tar
```

# 注意点

Conan Exiles はマシンスペックを非常に要求する。 Docker のデフォルト設定だとゲームサーバーの起動は失敗するため以下の様に、 Docker そのものの設定を変更すること。

* Docker コンテナのディスクスペースサイズを 30G 以上に拡張する必要あり。
* Docker コンテナの使用可能メモリを 8G 以上に拡張する必要あり。
* 当然だがコンテナを稼働させるホストマシンは上記ディスクスペースサイズ・メモリ容量以上のディスク空き容量・メモリ容量が必要である。
