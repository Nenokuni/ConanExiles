# 概要

ConanExiles Dedicated serverを自動で建てるDockerコンテナ。

# コンテナの構築から起動まで


# サーバー起動方法

コンテナ起動時に自動でゲームサーバーが起動しないように設定している。
* 設定の変更等を起動前に手動で行う場合を想定している。

コンテナにログイン
```
docker exec -it conan /bin/bash
```

サーバー起動
```
/start.sh
```

起動を確認する
```
screen -ls
screen -r conan
```

デタッチする
```
ctl-A ctl-d
```

ログアウト
```
exit
```

# データの保存先

ゲームサーバーデータ
```
/conan/server/ConanSandbox/Saved
```

キャッシュデータ
```
/root
```

ボリューム
```
conan_exiles
conan_exiles-wine
```

# 通常再起動手順

コンテナ停止
```
docker-compose stop
```

コンテナ起動
```
docker-compose start
```

コンテナにログイン
```
docker exec -it conan /bin/bash
```

サーバー起動
```
/start.sh
```

起動を確認する
```
screen -ls
screen -r conan
```

デタッチする
```
ctl-A ctl-d
```

ログアウト
```
exit
```

# ゲームサーバーアップデート手順

コンテナにログイン
```
docker exec -it conan /bin/bash
```

サーバーを停止
```
/kill.sh
```

アップデート
```
/update.sh
```

ログアウト
```
exit
```

# コンテナフルアップデート手順

ボリュームデータのバックアップ
```
docker run --rm --volumes-from conan -v conan-saved:/backup busybox tar cvf /backup/backup.tar /conan/server/ConanSandbox/Saved
docker run --rm --volumes-from conan -v conan-saved-wine:/backup busybox tar cvf /backup/backup.tar /root
```

dockerを落とす
```
docker-compose down -v
```

イメージを削除する
```
docker rmi conan:latest
```

イメージの再構築からコンテナの起動
```
docker-compose up -d --build
```

ボリュームデータのリストア
```
docker run --rm --volumes-from conan -v conan-saved:/backup busybox tar xvf /backup/backup.tar
docker run --rm --volumes-from conan -v conan-saved-wine:/backup busybox tar xvf /backup/backup.tar
```

# 注意点

* Dockerコンテナのディスクスペースサイズを30G以上に拡張する必要あり。
* Dockerコンテナの使用可能メモリを8G以上に拡張する必要あり。
