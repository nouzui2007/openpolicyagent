# Role-based Access Control (RBAC)
# --------------------------------
#
# ロールベースのアクセス制御サンプル。
# `admin` ロールは全てのURLを参照することができる。
# `writer` ロールはPOSTとPUTが許可されている。
# `reader` ロールあhGETが許可されている。
# `admin` 以外のロールには、個別にURLを指定して許可を出している。ここでは正規表現を使ったものと
# URLパラメータの評価例を行なっている。
#
# For more information see:
#
#	* Rego comparison to other systems: https://www.openpolicyagent.org/docs/latest/comparison-to-other-systems/
#	* Rego Iteration: https://www.openpolicyagent.org/docs/latest/#iteration

# パッケージはURLに反映される。この場合 `v1/data/jbapi/authz` でチェックを行う。
package jbapi.authz

# デフォルトは不許可
default allow = false

# adminロールは必ず許可
allow {
	user_is_admin
}

# ロールによって与えられた許可を満たしているか
allow {
	# ユーザーに与えられた権限データをgrant変数に入れる
	some grant
	user_is_granted[grant]

	# 取得した権限データからmethods要素を取り出して、入力値と比較。このときmethodsは配列なので、配列内に合致する要素があればtrueになる
	input.method == grant.methods[_]
  # 取得した権限データからresources要素を取り出して、入力値と正規表現で比較。このときのresourcesは配列。
	regex.globs_match(input.resource, grant.resources[_])
}

# ユーザーにadminロールがついているか
user_is_admin {

	# for some `i`...
	some i

	# "admin" is the `i`-th element in the user->role mappings for the identified user.
	data.user_roles[input.user][i] == "admin"
}

# この関数は入力されたユーザーにつけられたロールを取得し、ロールの権限を返す
user_is_granted[grant] {
	some i

	# 入力されたユーザーについたロールを、事前に登録したuser_rolesデータから取得する
	role := data.user_roles[input.user][i]

	# 取得したロールに与えられた権限を、事前に登録したrolesデータから取得して `grant` 変数にセット
  # `grant` 変数の内容が戻り値となる
	grant := data.role_grants[role]
}
