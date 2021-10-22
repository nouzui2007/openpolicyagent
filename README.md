# Journey Builder用ロールベース権限をOpen Policy Agentで実現できるか

## ロール系データの作成

### 登録

ロール定義を登録する。

```shell
curl -X PUT -H 'Content-Type:application/json' --data-binary @role_grants.json \
    localhost:8181/v1/data/role_grants
```

ユーザーとロールの紐付けを登録する。

```shell
curl -X PUT -H 'Content-Type:application/json' --data-binary @user_roles.json \
    localhost:8181/v1/data/user_roles
```


Regoで作成したポリシーを登録する。

```shell
curl -X PUT -H 'Content-Type: text/plain' --data-binary @jbapi_authz.rego \
    localhost:8181/v1/policies/jbapi_authz
```

### チェック

adminロールを与えられたalice

```shell
curl -s -X POST -H 'Content-Type:application/json' \
    localhost:8181/v1/data/jbapi/authz \
    -d @- <<EOS
{
  "input": {
    "user": "alice",
    "method": "DELETE",
    "resource": "hoge/moge/bob"
  }
}
EOS
```

reader, writerロールを与えられたbob

```shell
curl -s -X POST -H 'Content-Type:application/json' \
    localhost:8181/v1/data/jbapi/authz \
    -d @- <<EOS
{
  "input": {
    "user": "bob",
    "method": "POST",
    "resource": "hoge/moge/bob"
  }
}
EOS
```

bobはDELETEメソッドは使えない

```shell
curl -s -X POST -H 'Content-Type:application/json' \
    localhost:8181/v1/data/jbapi/authz \
    -d @- <<EOS
{
  "input": {
    "user": "bob",
    "method": "DELETE",
    "resource": "hoge/moge/bob"
  }
}
EOS
```

eveはGETで、hogeから始まるリソースのみにアクセスできる

```shell
curl -s -X POST -H 'Content-Type:application/json' \
    localhost:8181/v1/data/jbapi/authz \
    -d @- <<EOS
{
  "input": {
    "user": "eve",
    "method": "GET",
    "resource": "hoge/moge/bob"
  }
}
EOS
```

eveはPOSTできない

```shell
curl -s -X POST -H 'Content-Type:application/json' \
    localhost:8181/v1/data/jbapi/authz \
    -d @- <<EOS
{
  "input": {
    "user": "eve",
    "method": "POST",
    "resource": "hoge/moge/bob"
  }
}
EOS
```
