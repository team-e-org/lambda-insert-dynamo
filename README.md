attachTagのlambdaから
```json
{
  "pin": {
    "id": 2,
    "userId": 1,
    "title": "pin1",
    "description": "pin1 description",
    "imageUrl": "https://pinko-bucket.s3-ap-northeast-1.amazonaws.com/pins/009174cf-c4fe-4a49-a4b2-cb24a98887c9.png",
    "isPrivate": false,
    "createdAt": "2020-06-27 10:37:59",
    "updatedAt": "2020-06-27 10:37:59"
  },
  "tags": [
    {
      "id": 4,
      "tag": "neko"
    },
    {
      "id": 5,
      "tag": "inukkoro"
    },
    {
      "id": 6,
      "tag": "sushi"
    }
  ]
}
```
これを受け取り、dynamoDBにpinを挿入するようになっています。


## How to build zip file
mysql2のgemを使っているので、lambdaと同じ環境を用意してその中でzipにする必要があります。

`docker build -t lambda-ruby2.7-build-container .`

`docker run --rm -it -v $PWD:/var/task -w /var/task lambda-ruby2.7-bulild-container`

In docker container

`bundle config --local build.mysql2 --with-mysql2-config=/usr/lib64/mysql/mysql_config`

`bundle config --local silence_root_warning true`

`bundle install --path vendor/bundle --clean`

`mkdir -p /var/task/lib`

`cp -a /usr/lib64/mysql/*.so.* /var/task/lib/`

`zip -q -r deploy.zip .`
