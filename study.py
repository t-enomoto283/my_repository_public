import pandas as pd  # pandasをインポート

df = pd.read_csv('sales.csv')  # sales.csvを読み
print(df)  # 読んだ sales.csv の中身を確認

df["sales_amount"] = df["unit_price"] * df["quantity"]  # sales_amount のCOLUMNを追加

print(df)  # sales_amount COLUMNの追加を確認

product_sales = (
    df.groupby("product")["sales_amount"]
      .sum()
      .reset_index()
)  # 商品別の売上を集計

print(product_sales)  # 商品別の売上の集計を確認

product_sales = product_sales.sort_values(
    "sales_amount",
    ascending=False
)  # 売上順に並べる

print(product_sales)  # 売上順に並び変えた 商品別の売上集計 を確認

product_sales.to_csv(
    "product_sales.csv",
    index=False
)  # CSVに出力

df_product_sales = pd.read_csv("product_sales.csv")  # product_sales.csv を読み
print(df_product_sales)  # 読んだ product_sales.csv の中身を確認


### カテゴリー別の売上を出してみる
product_category_sales = (
    df.groupby("category")["sales_amount"]
      .sum()
      .reset_index()
)  # カテゴリー別の売上を集計

print(product_category_sales)  # カテゴリー別の売上集計を確認

product_category_sales = product_category_sales.sort_values(
    "sales_amount",
    ascending=False
)  # 売上順に並べる

print(product_category_sales)  # 並び変えたカテゴリー別の売上集計を確認

product_category_sales.to_csv(
    "product_category_sales.csv",
    index=False
)  # CSVに出力

df_product_category_sales = pd.read_csv("product_category_sales.csv")  # product_category_sales.csv を読み
print(df_product_category_sales)  # 読んだ product_category_sales.csv の中身を確認


### 「日付別の売上合計」や「日付×商品」や「10万円以上」をやってみる
date_sales = (
    df.groupby("date")["sales_amount"]
      .sum()
      .reset_index()
)  # 日付別の売上合計

print(date_sales)

date_sales = date_sales.sort_values(
    "sales_amount",
    ascending=False
)  # 売上順に並び変え

print(date_sales)

date_sales.to_csv(
    "date_sales.csv",
    index=False
)
df_date_sales = pd.read_csv("date_sales.csv")
print(df_date_sales)


date_product_sales = (
    df.groupby(["date", "product"])["sales_amount"]  # df.groupby(["col1", "col2"])[...] で複数カラムをリストで渡せる
      .sum()
      .reset_index()
)  # 日付×商品
print(date_product_sales)

date_product_sales = date_product_sales.sort_values(
    ["date", "product"],
    ascending=[True, True]
)
print(date_product_sales)

date_product_sales.to_csv(
    "date_product_sales.csv",
    index=False
)
df_date_product_sales = pd.read_csv("date_product_sales.csv")
print(df_date_product_sales)


df_100000_filtered = df[
    df["sales_amount"] >= 100000
]  # sales_amountが10万以上の行だけ抽出
print(df_100000_filtered)

df_not100000_filtered = df[
    df["sales_amount"] < 100000
]  # sales_amountが10万未満の行だけ抽出
print(df_not100000_filtered)


### 「カテゴリー×日付」をやってみる
date_category_sales = (
    df.groupby(["date", "category"])["sales_amount"]
      .sum()
      .reset_index()
)  # 日付×カテゴリー
print(date_category_sales)

date_category_sales = date_category_sales.sort_values(
    ["date", "category"],
    ascending=[True, True]
)
print(date_category_sales)

date_category_sales.to_csv(
    "date_category_sales.csv",
    index=False
)
df_date_category_sales = pd.read_csv("date_category_sales.csv")
print(df_date_category_sales)



### 次は「SQLのJOINに相当するmerge()」をやる
product_master = pd.DataFrame(
    {
    "product": ["A", "B", "C"],
    "product_name": ["商品A", "商品B", "商品C"],
    "supplier": ["X社", "Y社", "Z社"]
    }
)  # このような別の商品マスタがあるとする
print(product_master)

# 現在のdfには、
# product
# A
# B
# C
# しかない。そこで、売上データに商品名と仕入先を付けたいとする。

## 回答
df_merged = pd.merge(
    df,
    product_master,
    on="product",
    how="left"
)  # pd.merge(...) の場合
print(df_merged)

df.merge(
    product_master,
    on="product",
    how="left"
)  # 変数.merge(...) の場合

## pd.merge()の基本構文
# 基本形はこれ。
pd.merge(
    left_table,             # 左側のDataFrame
    right_table,            # 右側のDataFrame
    on="結合の基準にする列名",  # 両方のデータフレームで同じ名前の場合
    how="結合方法"
)  # how= "inner" =左右どちらにもある値だけ / "outer"　=左右どちらにしかない値も残す / "left" =左側を全部残す / "right" =右側を全部残す

## SQLで考えると
# SELECT
#   s.date,
#   s.product,
#   s.sales_amount,
#   m.product_name,
#   m.supplier
# FROM sales s LEFT JOIN product_master m
#   ON s.product = m.product;

## pd.merge(...) と 変数.merge(...) の違い
df.merge(
    product_master,
    on="product",
    how="left"
)
# 上記は pandas の merge() ではなく、df変数への merge()
# 今回のような「売上データを基準に商品マスタの情報を付ける」場合に非常に使いやすい。

# pd.merge(...) の場合は、左表と右表が引数に必要だが、変数.merge(...) もある。
# 例えば df.merge(product_master, on="product", how="left") は、
# df変数に対する merge() のため、すでに左表は df で、右表として product_master がきて、on="product" で結合し、how="left" で左側結合だ。

## 結合させるCOLUMN名が表間で異なる場合
仮に df変数 では "product_code"
仮に product_master変数 では "product"
# という、それぞれ異なる列名によって結合を行う場合、
df_merged = pd.merge(
    df,
    product_master,
    left_on="product_code",
    right_on="product",
    how="left"
)

# これはSQLのJOIN構文でON句を下記のように書くのと同じ
ON df.product_code = product_master.product

# 次は実際に、product_master に存在しない商品コードを1つ混ぜて、how="…" で結果がどう変わるか

## すでにあるテーブルに値を追加
df.loc[len(df)] = {
    "date": "2026-08-04",
    "product": "D",
    "category": "Keyboard",
    "quantity": 1,
    "unit_price": 10000
} # すでにある df を直接変更（=行を追加）

  # df.loc[...]
    # df.loc の.locは、DataFrameの行や列をラベルなどで指定してアクセスするためのもの。
    # 例えば、df.loc[0] なら、dfのインデックスが0の行を取得するという意味。
    # df.loc[0, "product"] なら、インデックス0の行のproduct列を取得する。
    # つまり、 df.loc[行, 列] という形で考えると分かりやすい。

print(df)  #　追加後、NULLの列値は、NaN と表示される
df["sales_amount"] = df["quantity"] * df["unit_price"] # 再計算の処理をすれば NaN の列値も反映される

product_master.loc[len(product_master)] = {
    "product": "W",
    "product_name": "商品W",
    "supplier": "W社"
}
print(product_master)

# ……というのを踏まえて、product_master に存在しない商品コードを df に1つ混ぜたので、how="…" で結果がどう変わるか見る

df.merge(
    product_master,
    on="product",
    how="left"
)  # 左側結合（=LEFT JOIN）

df.merge(
    product_master,
    on="product",
    how="right"
)  # 右側結合（=RIGHT JOIN）

df.merge(
    product_master,
    on="product",
    how="inner"
)  # 内部結合（=INNER JOIN）

df.merge(
    product_master,
    on="product",
    how="outer"
)  # 外部結合（=FULL OUTER JOIN）



### merge() についてもう一つ重要なテーマとされる ["1対1", "1対多", "多対1"] について
# 1対1、1対多、多対1 とは、「JOINするキーが、それぞれの表で何回登場するか」の話。

## 「1対1」
  # 例えば、商品マスタがこう。
    # product_master_1vs1
      # product  product_name
      # A        商品A
      # B        商品B
      # C        商品C
  # product がそれぞれ1回ずつしか登場していない。

product_master_1vs1 = pd.DataFrame(
    {
    "product": ["A", "B", "C"],
    "product_name": ["商品A", "商品B", "商品C"]
    }
)
print(product_master_1vs1)

  # 売上側も、
    # df_1vs1
      # product  sales_amount
      # A        100000
      # B        150000
      # C         30000
  # なら、

df_1vs1 = pd.DataFrame(
    {
    "product": ["A", "B", "C"],
    "sales_amount": [100000, 150000, 30000]
    }
)
print(df_1vs1)

  # df_1vs1          product_master_1vs1
    # A ───────────── A
    # B ───────────── B
    # C ───────────── C
  # となる。AはAと1件、BはBと1件、CはCと1件。これが1対1。

df_1vs1.merge(
    product_master_1vs1,
    on="product",
    how="left"
)

  # すると、
    # product  sales_amount  product_name
    # A        100000        商品A
    # B        150000        商品B
    # C         30000        商品C
  # で、行数は3行のまま。

## 「1対多」
  # 例えば、商品マスタでは商品Aは1件だけ。
    # product_master_1vsN
      # product  product_name
      # A        商品A
      # B        商品B
      # C        商品C

product_master_1vsN = pd.DataFrame(
    {
    "product": ["A", "B", "C"],
    "product_name": ["商品A", "商品B", "商品C"]
    }
)
print(product_master_1vsN)

  # 一方、売上データでは商品Aが何回も登場する。
    # df_1vsN
      # date        product  sales_amount
      # 8/1         A        100000
      # 8/2         A        120000
      # 8/3         A         80000
      # 8/1         B        150000

df_1vsN = pd.DataFrame(
    {
    "date": ["2026-08-1", "2026-08-2", "2026-08-3", "2026-08-1"],
    "product": ["A", "A", "A", "B"],
    "sales_amount": [100000, 120000, 80000, 150000]
    }
)
print(df_1vsN)

  # この場合、
    # product_master_1vsN   df_1vsN
      # A ───────────────── A（8/1）
      #                     A（8/2）
      #                     A（8/3）
      # B ───────────────── B（8/1）

  # つまり、商品マスタのA 1件に対して、売上データのAが3件 ある。これが1対多。

df_1vsN.merge(
    product_master_1vsN,
    on="product",
    how="left"
)

## 「多対1」
  # さっきの向きを逆に見ると、
    # df_1vsN             product_master_1vsN
      # A（8/1）──────────── A
      # A（8/2）────────────
      # A（8/3）────────────
      # B（8/1）──────────── B

  # 売上データから見ると、売上データの複数行 → 商品マスタの1行 なので、多対1とも言える。
  # つまり、 同じJOINでも、どちらを基準に見るかで呼び方が変わる。

## ここがデータエンジニアとして重要
# 例えば、
df.merge(
    product_master,
    on="product",
    how="left"
)
# をしたら、「商品マスタを付けただけだから、行数は変わらないだろう」と思ってしまうと危険。
# もし product_master側 に 同じproductの値 が複数存在していたら（=UNIQUEでなければ）、行数が爆増する可能性がある。

# だから実務では「キーが一意か」が重要で、商品マスタなら
  # product
  # A
  # B
  # C
# のように「product = 一意（UNIQUE）」であってほしい。

# キーのUNIQUE（一意性）は、Pythonでは下記構文で確認できる。
# データフレーム["キー"].is_unique
# Trueなら、product列の値が重複していない。Falseなら、productが重複している。
product_master["product"].is_unique
df["product"].is_unique

## わざと「非UNIQUEなキーの商品マスタ側とのJOINによって行数が増える現象」を体験する。
product_master_notUNIQUE = pd.DataFrame(
    {
    "product": ["A", "A", "A", "B", "C"],
    "product_name": ["商品A", "商品A", "商品A", "商品B", "商品C"]
    }
)
product_master_notUNIQUE["product"].is_unique

# まずは UNIQUEなキーの商品マスタ側とのLEFT JOIN
df.merge(
    product_master,
    on="product",
    how="left"
)  # → [6 rows × 8 columns]

# 次に 非UNIQUEなキーの商品マスタ側とのLEFT JOIN
df.merge(
    product_master_notUNIQUE,
    on="product",
    how="left"
)  # → [10 rows × 7 columns]



###  次は「merge() に validate= を指定すると、その結合関係が想定通りかPythonにチェックさせられる」というところ
# 例えば下記のように validate="…" を指定すると、
df.merge(
    product_master,
    on="product",
    how="left",
    validate="many_to_one"
)  # → merge() に「df側 は同じproductが複数（many）出てもよいが、product_master側 はproductが一意（one）であること」を期待する制約

# 以降は validate="one_to_one" / "one_to_many" / "many_to_many" を実際に試す
df.merge(
    product_master,
    on="product",
    how="left",
    validate="one_to_one"
)  # → pandas.errors.MergeError: Merge keys are not unique in left dataset; not a one-to-one merge

df.merge(
    product_master,
    on="product",
    how="left",
    validate="one_to_many"
)  # → pandas.errors.MergeError: Merge keys are not unique in left dataset; not a one-to-many merge

df.merge(
    product_master,
    on="product",
    how="left",
    validate="many_to_many"
)  # many_to_many は「左側 → manyでもOK | 右側 → manyでもOK」なので、今回の「df → many | product_master → one」も許容される。

# これまで、
df.merge(
    product_master,
    on="product",
    how="left"
)

# だったものに、validate="many_to_one" を加えることで、
df.merge(
    product_master,
    on="product",
    how="left",
    validate="many_to_one"
)

# 「売上データ側は同じ商品が何回出てもよいが、商品マスタ側の商品コードは一意であることを前提にJOIN」というデータ構造上の期待をコードに明示できる。
# これが大事で、実務的に考えると例えば本番環境で、
  # product_master
    # A
    # B
    # C
    # A ← 本来は UNIQUE であるべきキーに何らかの原因で重複データが入ってしまったとする。

# その後、JOIN自体は下記のように制約が無ければ実行されてしまい、売上データの行数が想定以上に増える可能性がある。
df.merge(
    product_master,
    on="product",
    how="left"
)

# しかし、validate="…" で merge() に制約を与えれば MergeError で止まるため「データ品質の前提条件をコードに持たせるための仕組み」となる。
df.merge(
    product_master,
    on="product",
    how="left",
    validate="many_to_one"
)



### 次は validate とセットで indicator=True をやる
df.merge(
    product_master,
    on="product",
    how="outer",    # 外部結合（FULL OUTER JOIN）=左右どちらにしかない値も残す
    indicator=True  # 結合結果に _merge のCOLUMNとその値が追加される
)

# 上記のように indicator=True を加えると、
  # _merge
    # both        ← 両方にある
    # left_only   ← 左表にしかない
    # right_only  ← 右表にしかない
# という列が追加され、「この行は 左表にしかないのか、右表にしかないのか、両方にあるのか」を確認できる。
# 今回の df における product D のような、商品マスタ未登録のデータを発見するのに実務的な機能である。

## 「売上データに存在するけど、商品マスタに登録されていない商品を探したい」という場合
result = df.merge(
    product_master,
    on="product",
    how="outer",
    indicator=True
)

unregistered_products = result[
    result["_merge"] == "left_only"
]  # _merge が left_only の行のみ抽出
print(unregistered_products)

## 逆に「商品マスタには登録されているけど、実際の売上データには登場していない商品を探したい」という場合
unused_products = result[
    result["_merge"] == "right_only"
]  # _merge が right_only の行のみ抽出
print(unused_products)

# ただし今回は、…how="outer", indicator=True としたから、左側のdfだけにあるDも 右側のproduct_masterだけにあるWも 両方出てきた。
df.merge(
    product_master,
    on="product",
    how="outer",
    indicator=True
)

# これが仮に、…how="left", indicator=True としていたら、左側のdfを基準にするので、右側のproduct_masterだけにあるWは 結果に出てこない。
df.merge(
    product_master,
    on="product",
    how="left",
    indicator=True
)

# また逆に、…how="right", indicator=True としていたら、右側のproduct_masterを基準にするので、左側のdfだけにあるDは 結果に出てこない。
df.merge(
    product_master,
    on="product",
    how="right",
    indicator=True
)

# つまり、下記のように整理もできる。
  # …how="left", indicator=True  → 左側を基準に差分を見る
  # …how="right", indicator=True → 右側を基準に差分を見る
  # …how="outer", indicator=True → 左右両方の差分を見る



### 「マスタと実データの差分チェック」を一つの処理にする

# 今までやってきたものを一つの実務っぽい処理にまとめます。
# 今回のデータは、
  # 売上データ df: ["A", "B", "C", "A", "B", "D"]
  # 商品マスタ product_master: ["A", "B", "C", "W"]
# したがって、「df → Dが余っている | master → Wが余っている」という状態。

# ① まずFULL OUTER JOINする
check_result = df.merge(
    product_master,
    on="product",
    how="outer",
    indicator=True
)
print(check_result)
  # ここまではもう理解済みですね。結果として下記になります。
    # A → both / B → both / C → both / D → left_only / W → right_only

# ② 「商品マスタ未登録商品」を抽出する
unregistered_products = check_result[
    check_result["_merge"] == "left_only"
]
print(unregistered_products)
  # これは、「売上データには存在するが、商品マスタには存在しない商品」です。今回なら、D ですね。

# ③ 「未販売商品」を抽出する
unused_products = check_result[
    check_result["_merge"] == "right_only"
]
print(unused_products)
  # これは、「商品マスタには存在するが、売上データには存在しない商品」です。今回なら、W です。

# ④ さらに「問題があるか」を判定する
  # ここから少し実務っぽくします。例えば、
if len(unregistered_products) > 0:
    print("商品マスタ未登録の商品があります")
else:
    print("商品マスタ未登録の商品はありません")
  # これで、「商品マスタ未登録の商品があります」と判定できます。

  # 同じように、「売上データに存在しない商品マスタがあります」ともできます。
if len(unused_products) > 0:
    print("売上データに存在しない商品マスタがあります")
else:
    print("すべての商品マスタが売上データに存在します")

# ⑤ ただし、ここで一つ重要な改善
  # 今回の目的が、「商品コードの差分だけを確認したい」なのであれば、check_resultの全列を見る必要はありません。
  # 例えば、
unregistered_products_loc = check_result.loc[
    check_result["_merge"] == "left_only",
    ["product"]
]
print(unregistered_products_loc)
  # とすれば、
    #   product
    # 5       D
  # だけになります。

  # 同様に、
unused_products_loc = check_result.loc[
    check_result["_merge"] == "right_only",
    ["product"]
]
print(unused_products_loc)
  # なら、
    #   product
    # 6       W
  # です。

  # ここで、
  # .loc[行の条件, 列]
  # という、以前やったdf.loc[...]の考え方がまた出来ます。

## せっかくなので、「差分があったらエラーとして扱う」ところをやってみる。
if not unregistered_products_loc.empty:
    print("エラー：商品マスタ未登録の商品があります")
    print(unregistered_products_loc)

if not unused_products_loc.empty:
    print("確認：売上データに存在しない商品マスタがあります")
    print(unused_products_loc)

  # ここで新しく出てきた、
DataFrame.empty
  # は、対象のDataFrameが空かどうかを確認するものです。
  # つまり、
not unregistered_products_loc.empty
  # なら、1件以上データがある という意味。

unregistered_products_loc.empty
unused_products_loc.empty
  # not を付けない .empty ならば、「対象のDataFrameがempty（空）である」の文脈で True / False となる。

not unregistered_products_loc.empty
not unused_products_loc.empty
  # not を付ければ否定形となるので、「対象のDataFrameがempty（空）ではない」の文脈で True / False となる。


## 関数化に進む（差分チェック）
def check_master_difference(data, master, key):
    import sys
    r = {}
    difference_check = data.merge(
        master,
        on=key,
        how="outer",
        indicator=True
    )
    result_left_only = difference_check.loc[
        difference_check["_merge"] == "left_only",
        [key]
    ]
    result_right_only = difference_check.loc[
        difference_check["_merge"] == "right_only",
        [key]
    ]
    if not result_left_only.empty:
        sys.stderr.write("エラー：商品マスタ未登録の商品があります\n")
        r["left_only"] = result_left_only
    if not result_right_only.empty:
        sys.stderr.write("確認：売上データに存在しない商品マスタがあります\n")
        r["right_only"] = result_right_only
    if result_left_only.empty and result_right_only.empty:
        sys.stderr.write("マスタと実データに差分はありません\n")
    return r

result = check_master_difference(df, product_master, "product")
print(result)
result["left_only"]
result["right_only"]


## 次は関数に validate を組み込んでみる
  # 「売上側は同じ商品が複数でもよい。しかし商品マスタ側の商品コードは一意でなければならない」というデータ品質上の前提をPythonに検証させる。
  # さらに、わざと「product_master_not_unique:A, A, B, C」のような重複マスタを作って、この関数を実行してみる。
  # そうするとMergeErrorが発生する。ここまでやると、下記のように実務っぽい一連の考え方が完成します。
  # 「mergeでデータを結合する」→「結合の前提条件をvalidateで保証する」→「indicatorで左右の差分を検出する」

# わざと、キーが一意ではない商品マスタ（重複版）を作る
product_master_not_unique = pd.DataFrame(
    {
    "product": ["A", "A", "A", "B", "B", "C", "W"],
    "product_name": ["商品A", "商品A", "商品A", "商品B", "商品B", "商品C", "商品W"]
    }
)
product_master_not_unique["product"].is_unique

# 新たに validate を組み込んだ関数化（差分チェック）
def check_master_difference_validate(data, master, key):
    import sys
    r = {}
    difference_check = data.merge(
        master,
        on=key,
        how="outer",
        validate="many_to_one",
        indicator=True
    )
    result_left_only = difference_check.loc[
        difference_check["_merge"] == "left_only",
        [key]
    ]
    result_right_only = difference_check.loc[
        difference_check["_merge"] == "right_only",
        [key]
    ]
    if not result_left_only.empty:
        sys.stderr.write("エラー：商品マスタ未登録の商品があります\n")
        r["left_only"] = result_left_only
    if not result_right_only.empty:
        sys.stderr.write("確認：売上データに存在しない商品マスタがあります\n")
        r["right_only"] = result_right_only
    if result_left_only.empty and result_right_only.empty:
        sys.stderr.write("マスタと実データに差分はありません\n")
    return r

# キーが一意ではない商品マスタ（.is_unique=False）を関数にかけてみる
check_master_difference_validate(df, product_master_not_unique, "product")
  # → pandas.errors.MergeError: Merge keys are not unique in right dataset; not a many-to-one merge

# キーが一意である商品マスタ（.is_unique=True）を関数にかけてみる
result_2 = check_master_difference_validate(df, product_master, "product")
print(result_2)
result_2["left_only"]
result_2["right_only"]


## 次は新たに、呼び出し側から結合関係を指定できる関数化（差分チェック）
  # 前までの関数では、validate="many_to_one" が固定されています。
  # つまり、関数を呼ぶたびに、「これは必ずmany-to-oneだ」という前提になっています。
  # そこで次は、呼び出し側から結合関係を指定できる関数にすると、下記のようにつながります。
  # 「関数に引数を渡す」というPythonの仕組みと、「データ処理のルールをパラメータ化する」という設計
  # ついでに先読みで、結合条件の指定も引数で渡せるようにする

def diff_relation_customize(data, master, key, how_join, validate_relation):
    """
    param data:左表
    param master:右表
    param key:結合COLUMN
    param how_join:"inner" / "left" / "right" / "outer"
    param validate_relation:"one_to_one" / "one_to_many" / "many_to_one" / "many_to_many"
    """
    import sys
    r = {}
    difference_check = data.merge(
        master,
        on=key,
        how=how_join,
        validate=validate_relation,
        indicator=True
    )
    result_left_only = difference_check.loc[
        difference_check["_merge"] == "left_only",
        [key]
    ]
    result_right_only = difference_check.loc[
        difference_check["_merge"] == "right_only",
        [key]
    ]
    if not result_left_only.empty:
        sys.stderr.write("エラー：商品マスタ未登録の商品があります\n")
        r["left_only"] = result_left_only
    if not result_right_only.empty:
        sys.stderr.write("確認：売上データに存在しない商品マスタがあります\n")
        r["right_only"] = result_right_only
    if result_left_only.empty and result_right_only.empty:
        sys.stderr.write("マスタと実データに差分はありません\n")
    return r

result_3 = diff_relation_customize(df, product_master, "product", "outer", "many_to_one")
  # → エラー：商品マスタ未登録の商品があります\n 確認：売上データに存在しない商品マスタがあります\n

result_4 = diff_relation_customize(df, product_master, "product", "inner", "many_to_one")
  # → マスタと実データに差分はありません

result_5 = diff_relation_customize(df, product_master, "product", "left", "one_to_one")
  # → pandas.errors.MergeError: Merge keys are not unique in left dataset; not a one-to-one merge

result_6 = diff_relation_customize(df, product_master, "product", "right", "many_to_many")
  # 確認：売上データに存在しない商品マスタがあります

# result_n の結果を確認する用途
for k, v in result_3.items():
    print(k, v)



### 次は関数を「実務で定期的に動かすデータ品質チェック」っぽくしていく

## 次のテーマ：差分チェックの結果をCSVに出す
  # 実務では画面に表示して終わりではなく、「今日のデータチェックで何が引っかかったか」を後から確認できるようにファイルに残したいことがあります。
  # そこでまず、下記のように出力してみます。
    # 商品マスタ未登録                  マスタにはあるが売上に存在しない
    # ↓                              ↓
    # unregistered_products.csv      unused_products.csv

  # まずは関数の外でやってみる。
    # 今のコードをそのまま利用して下記のようにした後、
result_dev = diff_relation_customize(df, product_master, "product", "outer", "many_to_one")

for d, p in result_dev.items():
    print(d, p)  # これは確認用

    # そして、次のようにやってみる。
if "left_only" in result_dev:
    result_dev["left_only"].to_csv(
        "unregistered_products.csv",
        index=False
    )
unregistered_products = pd.read_csv('unregistered_products.csv')  # 確認用

if "right_only" in result_dev:
    result_dev["right_only"].to_csv(
        "unused_products.csv",
        index=False
    )
unused_products = pd.read_csv('unused_products.csv')  # 確認用

    # 上記で考えてほしいこと……
      # if "left_only" in result_dev:  ← これは result_dev という辞書の中に、"left_only" というキーが存在するか？を確認しています。
      # 差分がなければ、関数ではそのキー自体を登録していません。
      # だから、result_dev["left_only"] をいきなり実行するより、if "left_only" in result_dev: として使うほうが安全です。

  # そして次に「件数」を返す。
    # 現在は、result_dev["left_only"] といった DataFrameそのもの を返しています。
    # しかし実務では、「商品マスタ未登録：1件, 未販売商品：1件」のような「件数」も欲しくなります。
    # 例えば、下記のようにすれば Dの件数 と Wの件数 を取得できます。
len(result_dev["left_only"])
len(result_dev["right_only"])

for k in result_dev:
  print([k],"の件数：",len(result_dev[k]), "件")

    # ただし、これも辞書に結果として持たせてみると面白い。例えば関数内に下記を追加するという形です。
      # r["left_only_count"] = len(result_left_only)
      # r["right_only_count"] = len(result_right_only)
    # すると、戻り値が下記のようになります。
      # {
      # "left_only": DのDataFrame,
      # "right_only": WのDataFrame,
      # "left_only_count": 1,
      # "right_only_count": 1
      # }

    # 早速「件数」も辞書に持たせる関数にしてみる。
def diff_relation_customize_2(data, master, key, how_join, validate_relation):
    """
    param data:左表
    param master:右表
    param key:結合COLUMN
    param how_join:"inner" / "left" / "right" / "outer"
    param validate_relation:"one_to_one" / "one_to_many" / "many_to_one" / "many_to_many"
    """
    import sys
    r = {}
    difference_check = data.merge(
        master,
        on=key,
        how=how_join,
        validate=validate_relation,
        indicator=True
      )
    result_left_only = difference_check.loc[
        difference_check["_merge"] == "left_only",
        [key]
    ]
    result_right_only = difference_check.loc[
        difference_check["_merge"] == "right_only",
        [key]
    ]
    if not result_left_only.empty:
        sys.stderr.write("エラー：商品マスタ未登録の商品があります\n")
        r["left_only"] = result_left_only
        r["left_only_count"] = len(result_left_only)
    if not result_right_only.empty:
        sys.stderr.write("確認：売上データに存在しない商品マスタがあります\n")
        r["right_only"] = result_right_only
        r["right_only_count"] = len(result_right_only)
    if result_left_only.empty and result_right_only.empty:
        sys.stderr.write("マスタと実データに差分はありません\n")
    return r

dc2 = diff_relation_customize_2(df, product_master, "product", "outer", "many_to_one")

    # 確認用
dc2.keys()
dc2["left_only_count"]
dc2["right_only_count"]
for k, v in dc2.items():
    print(k, v)

  # さらにその先：「エラー」と「確認」を分ける
    # ここがデータ品質チェックとして重要で、今回「D → 商品マスタに存在しない / W → 商品マスタにあるが売上データに登場しない」でした。
    # この2つを同じ「差分」として扱っていますが、業務上の重大度は同じとは限りません。

    # 例えば、
      # D：商品マスタ未登録
      # 売上データ
      # ↓
      # 存在しない商品コード
      # ↓
      # 商品名・仕入先などを正しく付与できない
    # ならば、「エラー：後続処理を止める」という判断もあり得ます。

    # 一方で、
      # W：商品マスタにはあるが売上データに登場しない
      # 商品マスタ
      # ↓
      # 今月売れていないだけ
    # ならば、「確認：処理は継続する」という扱いもできます。

    # つまり、
      # left_only    right_only
      # ↓            ↓
      # ERROR        WARNING
    # というように、異常の種類によって扱いを変えるわけです。

    # 早速「ログレベル」を組み込んだ（sys.stderr.write('…')を併用する）関数にしてみる
def diff_relation_customize_3(data, master, key, how_join, validate_relation):
    """
    param data:左表
    param master:右表
    param key:結合COLUMN
    param how_join:"inner" / "left" / "right" / "outer"
    param validate_relation:"one_to_one" / "one_to_many" / "many_to_one" / "many_to_many"
    """
    import logging
    import sys
    r = {}
    difference_check = data.merge(
        master,
        on=key,
        how=how_join,
        validate=validate_relation,
        indicator=True
      )
    result_left_only = difference_check.loc[
        difference_check["_merge"] == "left_only",
        [key]
    ]
    result_right_only = difference_check.loc[
        difference_check["_merge"] == "right_only",
        [key]
    ]
    if not result_left_only.empty:
        logging.error('ERROR：商品マスタ未登録の商品があります\n')
        r["left_only"] = result_left_only
        r["left_only_count"] = len(result_left_only)
    if not result_right_only.empty:
        logging.warning('WARNING：売上データに存在しない商品マスタがあります\n')
        r["right_only"] = result_right_only
        r["right_only_count"] = len(result_right_only)
    if result_left_only.empty and result_right_only.empty:
        sys.stderr.write("マスタと実データに差分はありません\n")
    return r

    # ただし、これも辞書に結果として持たせてみると面白い。例えば関数内に下記を追加するという形です。
      # r["left_only_count"] = len(result_left_only)
      # r["right_only_count"] = len(result_right_only)
    # すると、戻り値が下記のようになります。
      # {
      # "left_only": DのDataFrame,
      # "right_only": WのDataFrame,
      # "left_only_count": 1,
      # "right_only_count": 1
      # }

dc3 = diff_relation_customize_3(df, product_master, "product", "outer", "many_to_one")

    # 確認用
dc3.keys()
dc3["left_only_count"]
dc3["right_only_count"]
for k, v in dc3.items():
    print(k, v)

  # ここまで来るとデータ基盤っぽい
    # 例えば最終的には…
      # データ取得
      #    ↓
      # JOIN
      #    ↓
      # validate
      #    ↓
      # 差分チェック
      #    ↓
      #  ┌───────────────┐
      #  │               │
      # Dがある          Wがある
      #  │               │
      # ERROR            WARNING
      #  │               │
      # 処理停止         処理継続

    # みたいな処理をPythonで組めるようになります。
    # さらに、下記までいけば、単なるpandas練習から「ETL/ELTやデータ品質管理の考え方」にかなり近づきます。
      # チェック結果
      # ↓
      # CSV保存
      # ↓
      # ログ出力
      # ↓
      # 件数集計
      # ↓
      # 異常なら後続処理を止める

  # チェック結果 → CSV保存 → ログ出力 → 件数集計 → 異常なら後続処理を止める
def diff_result_csv_datacheck(data, master, key, how_join, validate_relation):
    """
    param data:左表
    param master:右表
    param key:結合COLUMN
    param how_join:"inner" / "left" / "right" / "outer"
    param validate_relation:"one_to_one" / "one_to_many" / "many_to_one" / "many_to_many"
    """
    import logging
    import sys
    r = {}
    difference_check = data.merge(
        master,
        on=key,
        how=how_join,
        validate=validate_relation,
        indicator=True
      )
    result_left_only = difference_check.loc[
        difference_check["_merge"] == "left_only",
        [key]
    ]
    result_right_only = difference_check.loc[
        difference_check["_merge"] == "right_only",
        [key]
    ]
    if not result_left_only.empty:
        r["left_only"] = result_left_only
        r["left_only_count"] = len(result_left_only)
        logging.error('ERROR：商品マスタ未登録の商品があります\n')
        print('エラー', len(result_left_only), '件')
    if not result_right_only.empty:
        r["right_only"] = result_right_only
        r["right_only_count"] = len(result_right_only)
        logging.warning('WARNING：売上データに存在しない商品マスタがあります\n')
        print('要確認', len(result_right_only), '件')
    if result_left_only.empty and result_right_only.empty:
        sys.stderr.write("マスタと実データに差分はありません\n")
    if "left_only" in r:
        r["left_only"].to_csv(
            "unregistered_products.csv",
            index=False
        )
    if "right_only" in r:
        r["right_only"].to_csv(
            "unused_products.csv",
            index=False
        )
    return r

diff_result_csv_datacheck(df, product_master, "product", "outer", "many_to_one")

  ## FBによると……
    # merge → validate → indicator → 差分検出 → 件数 → ログ → CSV出力 を、ひとつの「データ品質チェック処理」にまとめようとしている。
    # これは、今あなたが目指しているデータ基盤・データエンジニアの仕事の考え方にかなり近いです。
    # ただし、ここで一度立ち止まって、コード上の重要なポイントを2つだけ整理してから次へ進むのがいいと思います。

  # まず、今回のコードでできていること
    # 最終的な関数
      # def diff_result_csv_datacheck(data, master, key, how_join, validate_relation):
      # ……
    # に対して、
      # diff_result_csv_datacheck(df, product_master, "product", "outer", "many_to_one") と渡す。
    # すると、下記の一連の処理になるがこれ自体は良く、特に、validate="many_to_one" を入れているので、
    # 「売上データは同じ商品コードが複数でもいい。しかしマスタの商品コードは一意でなければならない」というデータ品質上のルールを埋め込めている。
      # df（売上データ）
      #         ↓
      #       merge
      #         ↓
      #    validate
      #         ↓
      #    indicator
      #         ↓
      #    差分を判定
      #       ↙   ↘
      #  Dがある    Wがある
      #     ↓         ↓
      #   ERROR     WARNING
      #     ↓         ↓
      #  CSV保存    CSV保存

  # 重要なポイント①
    # 今回、下記としているので、left_only は、「売上データ側には存在するが、マスタ側には存在しないキー」です。
result_left_only = difference_check.loc[
    difference_check["_merge"] == "left_only",
    [key]
]

    # したがって、次のように記述するのは、今回の業務ルールならOK。
logging.error(...)

    # 一方、下記は、「マスタには存在するが、売上データには存在しないキー」です。
result_right_only = difference_check.loc[
    difference_check["_merge"] == "right_only",
    [key]
]

    # これを次のように記述しているのも、「未販売なだけかもしれないので処理は継続」という今回設定した業務ルールとしてはOKです。
logging.warning(...)

    # つまり、
      # left_only  → ERROR
      # right_only → WARNING
    # は、pandasが決めているわけではなく、あなたが業務ルールとして決めている。ここはデータエンジニアとして結構重要なポイントです。

  # 重要なポイント② logging はまだ少しだけ違う
    # このような記述をしていますが、
logging.error('ERROR：商品マスタ未登録の商品があります\n')

    # logging は本来、下記構文のような、ログの出力先やレベルの設定時に使うものです。
logging.basicConfig(...)

    # 今の段階では、
print(...)
    # と混ぜても動きますが、次の段階では、
      # logging.error(...)
      # logging.warning(...)
      # logging.info(...)
    # をちゃんと使う練習をした方がいい。
    # ただ、今すぐloggingの仕組みまで掘らなくていいです。
    # 今やっている学習の本筋は、「データを処理して、品質をチェックし、異常を検出する」ことだからです。

## 本来 logging はログの出力先やレベルの設定時に使うものなので、改めて修正版のコードをここで作る
def diff_result_csv_datacheck(data, master, key, how_join, validate_relation):
    """
    param data:左表
    param master:右表
    param key:結合COLUMN
    param how_join:"inner" / "left" / "right" / "outer"
    param validate_relation:"one_to_one" / "one_to_many" / "many_to_one" / "many_to_many"
    """
    import sys
    r = {}
    difference_check = data.merge(
        master,
        on=key,
        how=how_join,
        validate=validate_relation,
        indicator=True
      )
    result_left_only = difference_check.loc[
        difference_check["_merge"] == "left_only",
        [key]
    ]
    result_right_only = difference_check.loc[
        difference_check["_merge"] == "right_only",
        [key]
    ]
    if not result_left_only.empty:
        r["left_only"] = result_left_only
        r["left_only_count"] = len(result_left_only)
        sys.stderr.write('ERROR：商品マスタ未登録の商品があります\n')
        print('エラー', len(result_left_only), '件')
    if not result_right_only.empty:
        r["right_only"] = result_right_only
        r["right_only_count"] = len(result_right_only)
        sys.stderr.write('WARNING：売上データに存在しない商品マスタがあります\n')
        print('要確認', len(result_right_only), '件')
    if result_left_only.empty and result_right_only.empty:
        sys.stderr.write("マスタと実データに差分はありません\n")
    if "left_only" in r:
        r["left_only"].to_csv(
            "unregistered_products.csv",
            index=False
        )
    if "right_only" in r:
        r["right_only"].to_csv(
            "unused_products.csv",
            index=False
        )
    return r

diff_result_csv_datacheck(df, product_master, "product", "outer", "many_to_one")

  # そして、今回かなり重要なこと
    # コードの後半には下記があります。
      # if "left_only" in r:
      #     r["left_only"].to_csv(
      #         "unregistered_products.csv",
      #         index=False
      #     )

    # これは前にやった、下記理解がそのまま関数の中に生きています。
      # if "left_only" in result_dev:

    # つまり、r = {} から始めて、
      # if not result_left_only.empty:
      #     r["left_only"] = result_left_only

    # だから、差分の結果によって次のようになる。
      # 差分あり
        # r = {
        #     "left_only": DataFrame,
        #     "left_only_count": 1
        # }
      # 差分なし
        # r = {}

    # だから、if "left_only" in r: としておけば、
    # 「left_onlyという結果が生成された場合だけCSVに出力する」という自然な処理です。

  # ただ、一つだけ「データ基盤っぽさ」を上げるなら...
    # 今は下記のような辞書構造ですね。
    # r["left_only"]
    # r["right_only"]
    # r["left_only_count"]
    # r["right_only_count"]

  # ここまで来たら次は「結果をどう設計するか」を考えるべきで、今は下記のような結果を返しているがこれ自体は悪くない。
    # {
    #     "left_only": DのDataFrame,
    #     "right_only": WのDataFrame,
    #     "left_only_count": 1,
    #     "right_only_count": 1
    # }

  # ただ実務ではさらに、以下のようなみたいな「チェック全体の状態」が欲しくなります。
    # status
    # error_count
    # warning_count

  # 例えば今回の例で考えるなら以下のような形。
    # {
    #     "status": "ERROR",
    #     "error_count": 1,
    #     "warning_count": 1,
    #     "left_only": ...,
    #     "right_only": ...
    # }

  # そうすると後続処理で、下記のようにできます。
    # if result["status"] == "ERROR":
    #     # 後続処理を止める


## 「チェック全体の状態」に加えて、次の「ERRORなら後続処理を止める」をやってみる
  # 今回のケース例でいうと……
    # データ取得
    #    ↓
    # マスタチェック
    #    ↓
    # ERROR？
    #  ┌───┴───┐
    #  YES     NO
    #   ↓       ↓
    # 停止     次へ
    #           ↓
    #       データ加工
    #           ↓
    #       CSV出力

  # という流れです。
  # ここで始めて return が単なる「値を返すための文」ではなく、「前工程の結果を受け取って、後工程を進める／止める」ために使えることが体感できる。
  # そしてその次に、「この処理を毎日手動で実行するのではなく、決まった順番で自動実行する」という所へ進めば、ETL/ELT・パイプラインの話に入れる。

## 「チェック全体の状態」に加えて「ERRORなら後続処理を止める」関数を作る
def diff_result_checker(data, master, key, how_join, validate_relation):
    """
    param data:左表
    param master:右表
    param key:結合COLUMN
    param how_join:"inner" / "left" / "right" / "outer"
    param validate_relation:"one_to_one" / "one_to_many" / "many_to_one" / "many_to_many"
    """
    import sys
    r = {}
    difference_check = data.merge(
        master,
        on=key,
        how=how_join,
        validate=validate_relation,
        indicator=True
      )
    result_left_only = difference_check.loc[
        difference_check["_merge"] == "left_only",
        [key]
    ]
    result_right_only = difference_check.loc[
        difference_check["_merge"] == "right_only",
        [key]
    ]
    if not result_left_only.empty:
        r["left_only"] = result_left_only
        r["left_only_count"] = len(result_left_only)
        r["error_status"] = "ERROR"
        r["error_count"] = len(result_left_only)
        sys.stderr.write('ERROR：商品マスタ未登録の商品があります。\n')
    if not result_right_only.empty:
        r["right_only"] = result_right_only
        r["right_only_count"] = len(result_right_only)
        r["warning_status"] = "WARNING"
        r["warnings_count"] = len(result_right_only)
        sys.stderr.write('WARNING：売上データに存在しない商品マスタがあります。\n')
    if result_left_only.empty and result_right_only.empty:
        sys.stderr.write("マスタと実データに差分はありません\n")
    if r.get("error_status") == "ERROR":
        raise Exception("商品マスタ未登録が見つかり後続処理のCSV出力を止めました。")
    if "right_only" in r:
        r["right_only"].to_csv(
            "unused_products.csv",
            index=False
        )
    return r

# ERRORが発生する版での実行例
diff_result_checker(df, product_master, "product", "outer", "many_to_one")
  # 結果
    # ERROR：商品マスタ未登録の商品があります。
    # WARNING：売上データに存在しない商品マスタがあります。
    # Traceback(most recent call last):
    #   File "<input>", line 1, in <module>
    #   File "<input>", line 41, in diff_result_checker
    # Exception: 商品マスタ未登録が見つかり後続処理のCSV出力を止めました。

clean_df = pd.DataFrame(
    {
    "date": ["2026-08-1", "2026-08-2", "2026-08-3", "2026-08-1"],
    "product": ["A", "A", "B", "C"],
    "sales_amount": [120000, 120000, 80000, 50000]
    }
)

# ERRORが発生しない版での実行例　
diff_result_checker(clean_df, product_master, "product", "outer", "many_to_one")
  # 結果
    # WARNING：売上データに存在しない商品マスタがあります。
    # {'right_only':   product
    # 4       W, 'right_only_count': 1, 'warning_status': 'WARNING', 'warnings_count': 1}


  ## FBによると...
    # はい。ちゃんと狙った動きになっています。
    # そして今回の一番大事なところは、実際に Exception を発生させて、ERRORになったら後続処理に進まないことを確認できた点です。
    # 今のコードには「次から直すと実務っぽくなるポイント」があるので、コードを整理しましょう。

  # まず今回できていること
    # ERRORケースの場合、下記により、「merge → 差分チェック → D発見 → ERROR → raise Exception → そこで処理終了」になっています。
      # if r.get("error_status") == "ERROR":
      #     raise Exception("商品マスタ未登録が見つかり後続処理のCSV出力を止めました。)
    # そのためERRORケースでは、この下に書いたCSV出力には到達しません。これは狙い通りです。
      # if "right_only" in r:
      #     r["right_only"].to_csv("unused_products.csv", index=False)

    # 一方でERRORケースとならない clean_df を使った想定では、 left_only が存在しないので、下記となる。
      # r.get("error_status") は None
      # r.get("error_status") == "ERROR" は False。
    # しがたって以降の処理が続き、「WARNING → unused_products.csvへ出力 → return r」となる。ここまでの制御フローは理解できています。

  ## 直したいところ
    # 今は
r["error_status"] = "ERROR"
r["error_count"] = len(result_left_only)

    # と下記をそれぞれ「差分があったときだけ」辞書に入れています。これは動きますが、ちょっと扱いづらいです。
r["warning_status"] = "WARNING"
r["warnings_count"] = len(result_right_only)

    # 例えば差分がない場合、r には {} しかありません。WARNINGだけなら下記です。
      # {
      # "right_only": ...,
      # "right_only_count": 1,
      # "warning_status": "WARNING",
      # "warnings_count": 1
      # }

    # つまり、結果の構造が状況によって変わるため、ここは次の段階で下記のように最初から「チェック結果の骨格」を作っておくと綺麗です。
      # r = {
      #     "status": "OK",
      #     "error_count": 0,
      #     "warning_count": 0
      # }

    # あらかじめ上記のようにしておき、そしてDがあったら下記、
      # r["status"] = "ERROR"
      # r["error_count"] = len(result_left_only)
      # r["left_only"] = result_left_only
    # Wがあったら下記という形です。
      # r["warning_count"] = len(result_right_only)
      # r["right_only"] = result_right_only

    # すると今回のデータなら下記となる。
      # {
      #    "status": "ERROR",
      #     "error_count": 1,
      #     "warning_count": 1,
      #     "left_only": ...,
      #     "right_only": ...
      # }
    # ERRORがなければ、下記となる。
      # {
      #     "status": "WARNING",
      #     "error_count": 0,
      #     "warning_count": 1,
      #     "right_only": ...
      # }
    # ERROR も WARNING もなければ下記となり、常に同じ構造で結果を返せる。これが結構重要です。
      # {
      #     "status": "OK",
      #     "error_count": 0,
      #     "warning_count": 0
      # }

    # そして、raise Exception(...) を使っており、これは今回の学習としては正しいが実務でデータパイプラインを作るなら
    # raise ValueError や、場合によっては独自の例外を使ったり、下記の形で受け取ったりするべき。
      # try:
      #     ...
      # except ...

  # 次は、今の関数を少し整理して下記を綺麗な一つの関数として完成させましょう。
    #                                                  ┌ ERROR    → 処理停止
    # データ → merge → validate → indicator → 差分チェック
    #                                                  └ WARNING  → 処理継続 → CSV保存

  # そしてそこで、「データを整え、組み合わせ、その結果を使い分析でき、それが毎回手作業をせず使える状態」が具体的な形で見えてきます。
    # Python → CSV / DBからデータ取得 → 加工 → JOIN → 品質チェック → エラーなら停止 → 問題なければ次の加工 → 分析用データを出力
  # なので、次は status / error_count / warning_count を最初から持つ形にリファクタリングしてみましょう。

## あらかじめ「チェック結果の骨格」を作っておき、常に同じ構造で結果を返せるように修正する
def data_diff_checker(data, master, key, how_join, validate_relation):
    """
    param data:左表
    param master:右表
    param key:結合COLUMN
    param how_join:"inner" / "left" / "right" / "outer"
    param validate_relation:"one_to_one" / "one_to_many" / "many_to_one" / "many_to_many"
    """
    import sys
    r = {
        "status": "OK",
        "error_count": 0,
        "warning_count": 0
    }
    difference_check = data.merge(
        master,
        on=key,
        how=how_join,
        validate=validate_relation,
        indicator=True
      )
    result_left_only = difference_check.loc[
        difference_check["_merge"] == "left_only",
        [key]
    ]
    result_right_only = difference_check.loc[
        difference_check["_merge"] == "right_only",
        [key]
    ]
    if not result_right_only.empty:  # ERRORとWARNINGが共に生じるケースを想定して先にWARNINGを処理
        r["status"] = "WARNING"
        r["warning_count"] = len(result_right_only)
        r["right_only"] = result_right_only
        sys.stderr.write('WARNING：売上データに存在しない商品マスタがあります。\n')
    if not result_left_only.empty:
        r["status"] = "ERROR"
        r["error_count"] = len(result_left_only)
        r["left_only"] = result_left_only
        try:
            raise Exception("商品マスタ未登録が見つかり後続処理を止めました。")
        except Exception as err:
            print("ERROR:", err)
        return r
    if result_left_only.empty and result_right_only.empty:
        sys.stderr.write("マスタと実データに差分はありません\n")
    if r["warning_count"] > 0:
        r["right_only"].to_csv(
            "unused_products.csv",
            index=False
        )
    return r

# ERROR と WARNING が発生する版での試行
data_diff_checker(df, product_master, "product", "outer", "many_to_one")
  # 結果
    # WARNING：売上データに存在しない商品マスタがあります。
    # ERROR: 商品マスタ未登録が見つかり後続処理を止めました。
    # {'status': 'ERROR', 'error_count': 1, 'warning_count': 1, 'right_only':   product
    # 6       W, 'left_only':   product
    # 5       D}

# WARNING だけ発生する版での試行
data_diff_checker(clean_df, product_master, "product", "outer", "many_to_many")
  # 結果
    # WARNING：売上データに存在しない商品マスタがあります。
    # {'status': 'WARNING', 'error_count': 0, 'warning_count': 1, 'right_only':   product
    # 4       W}



### 「チェックする処理」と「実際にデータを加工する処理」を分離する

# メモ：
  # 既存の data_diff_checker は、.to_csvの処理はなくして完全に差分の有無を見る品質チェッカーだけの役割にする
  # さらに、exception例外による送出ではなく、sys.stderr.write('…') の形にする

# ここまでで、「データ → merge → validate → indicator → 差分チェック → ERROR / WARNING / OK」まで作れています。
# 次はこれを、「① データ品質チェック → OKなら次へ → ② データ加工 → ③ CSVなどへ出力」という処理の流れにします。

  ## まず「チェック」と「加工」を別々の関数にする
  # 今までは data_diff_checker() の中に、CSV出力なども入っていました。ここでは一旦、それを分けます。

    # まず、あなたがすでに作ったチェック関数はそのまま使います。
check_result = data_diff_checker(df, product_master, "product", "outer", "many_to_one")

    # 上記によって、次のような結果を受け取れるわけですね。
      # {
      #     "status": "ERROR",
      #     "error_count": 1,
      #     "warning_count": 1,
      #     "right_only": ...,
      #     "left_only": ...
      # }

  ## 次に「データ加工」の関数を作る
    # 例えば今回なら、「商品マスタを売上データに結合して、商品名・仕入先を付ける」という処理を別の関数にします。
    # ここで重要なのは、この関数はデータ品質チェックをしないこと。
    # ただ「売上データ + 商品マスタ → 商品名・仕入先が付いたデータ」を作る仕事だけを担当する、下記のような形です。
      # def transform_sales_data(data, master):
      #     result = data.merge(
      #         master,
      #         on="product",
      #         how="left",
      #         validate="many_to_one"
      #     )
      #     return result

  ## そして「呼び出し側」で判断する
    # ここが今回の一番重要なところです。
    # check_result = data_diff_checker(df, product_master, "product", "outer", "many_to_one")

    # if check_result["status"] == "ERROR":
    #     print("ERRORのため、後続処理を停止します。")
    # else:
    #     transformed_data = transform_sales_data(
    #         df,
    #         product_master
    #     )
    #     print(transformed_data)

  ## 流れは下記となり、これがまさに、「前工程の結果によって後工程を実行するか決める」という考え方です。
    # data_diff_checker()
    #                  ↓
    #              チェック結果
    #                  ↓
    #             statusを見る
    #            /          \
    #        ERROR          OK/WARNING
    #         ↓                ↓
    #        停止            transform_sales_data()
    #                          ↓
    #                       加工されたdf

  ## WARNINGならどうする？
    # ここも今まで勉強してきたことが効いてきます。
    # 今回の設計では、下記としています。
      # ERROR → 処理停止
      # WARNING → 処理継続
      # OK → 処理継続

    # なので、下記により「ERROR → 停止 / WARNING → 続行 / OK → 続行」となります。
      # if check_result["status"] == "ERROR":
      #     print("ERRORのため、後続処理を停止します。")
      # else:
      #     transformed_data = transform_sales_data(
      #         df,
      #         product_master
      #     )

    # ERROR とならない正常データで流した場合、下記となります。
    # 「WARNING → status = WARNING → ERRORではない → 後続処理へ → transform_sales_data()」

    # 今回作っているものは、次のようなデータパイプラインの一部になっています。
      # ① データを受け取る
      #         ↓
      # ② マスタとの整合性を検証
      #         ↓
      # ③ データ品質に問題がないか判定
      #         ↓
      # ④ 問題の種類によって処理を継続／停止
      #         ↓
      # ⑤ データを加工
      #         ↓
      # ⑥ 加工済みデータを次工程へ渡す

    # そして重要なのは、check_result = ... と transformed_data = ... を分けたことです。
    # つまり、「チェックする処理」と「データを加工する処理」を別々の責務にした点で、これが次の段階でかなり重要になります。


### まずはここまでを踏まえて「チェックする処理」と「実際にデータを加工する処理」を分離するコードを書いてみる
  # ここではまだ「自動実行」「スケジューラー」には進みません。
  # 「チェック → 判定 → OKなら加工」という一本の流れを、自分の手で組めるようにしましょう。
  # それができたら、その次に「データ取得 → データ品質チェック → データ加工 → CSV出力」を一つのパイプラインとして関数から呼び出す所へ進める。

## データ品質（差分）チェックの関数
def data_diff_checker(data, master, key, how_join, validate_relation):
    """
    param data:左表
    param master:右表
    param key:結合COLUMN
    param how_join:"inner" / "left" / "right" / "outer"
    param validate_relation:"one_to_one" / "one_to_many" / "many_to_one" / "many_to_many"
    """
    import sys
    r = {
        "status": "OK",
        "error_count": 0,
        "warning_count": 0
    }
    difference_check = data.merge(
        master,
        on=key,
        how=how_join,
        validate=validate_relation,
        indicator=True
      )
    result_left_only = difference_check.loc[
        difference_check["_merge"] == "left_only",
        [key]
    ]
    result_right_only = difference_check.loc[
        difference_check["_merge"] == "right_only",
        [key]
    ]
    if not result_right_only.empty:  # ERRORとWARNINGが共に生じるケースを想定して先にWARNINGを処理
        r["status"] = "WARNING"
        r["warning_count"] = len(result_right_only)
        r["right_only"] = result_right_only
        sys.stderr.write('WARNING：売上データに存在しない商品マスタがあります。\n')
    if not result_left_only.empty:
        r["status"] = "ERROR"
        r["error_count"] = len(result_left_only)
        r["left_only"] = result_left_only
        sys.stderr.write('ERROR：商品マスタ未登録が見つかりました。')
        return r
    if result_left_only.empty and result_right_only.empty:
        sys.stderr.write("マスタと実データに差分はありません\n")
    return r

## データ加工の関数（今回は商品マスタを売上データに結合して商品名・仕入先を付けるという処理）
def transform_sales_data(data, master):
    result = data.merge(
        master,
        on="product",
        how="left",
        validate="many_to_one"
    )
    return result

## コールする側（呼び出し側）で判断する
check_result_d = data_diff_checker(df, product_master, "product", "outer", "many_to_one")
  # → WARNING：売上データに存在しない商品マスタがあります。
  # → ERROR：商品マスタ未登録が見つかりました。

check_result_c = data_diff_checker(clean_df, product_master, "product", "outer", "many_to_one")
  # → WARNING：売上データに存在しない商品マスタがあります。

## 下記はERRORとなる版での試行
if check_result_d["status"] == "ERROR":
    print("ERRORのため、後続処理を停止します。")
else:
    td_e = transform_sales_data(df, product_master)
    print(td_e)
  # → ERRORのため、後続処理を停止します。

## 下記はERRORとならない版での試行
if check_result_c["status"] == "ERROR":
    print("ERRORのため、後続処理を停止します。")
else:
    td_c = transform_sales_data(clean_df, product_master)
    print(td_c)
  # →         date product  sales_amount product_name supplier
  # → 0  2026-08-1       A        120000         商品A       X社
  # → 1  2026-08-2       A        120000         商品A       X社
  # → 2  2026-08-3       B         80000         商品B       Y社
  # → 3  2026-08-1       C         50000         商品C       Z社


### 次に進み「一連の処理そのものを一つの関数にまとめる」をする
  # 今は呼び出し側に、下記のように書いています。
    # check_result = data_diff_checker(...)
    # if check_result["status"] == "ERROR":
    #     ...
    # else:
    #     transformed_data = transform_sales_data(...)

  # これを一段進め、「①データ取得 → ②データ品質チェック → ③ERRORなら停止 → ④データ加工 → ⑤CSV出力」という一連の処理を一つの関数する。
  # つまり、これまで作ってきた部品を組み合わせます。
  # "イメージ"としては、下記のようなという形です。
    # def run_pipeline(data, master):
    #     ① チェック
    #     check_result = data_diff_checker(...)
    #     ② ERRORなら停止
    #     if check_result["status"] == "ERROR":
    #         return check_result
    #     ③ データ加工
    #     transformed_data = transform_sales_data(...)
    #     ④ CSV出力
    #     transformed_data.to_csv(...)
    #     ⑤ 結果を返す
    #     return ...

  # ここで初めて、「個々の処理を書ける」から「処理を順番につなげられる」に進みます。
  # そして、この「順番につながった処理」が、まさにあなたが最初に話していたデータパイプラインを理解する入口になります。


### run_pipeline() に「①データ取得 → ②データ品質チェック → ③ERRORなら停止 → ④データ加工 → ⑤CSV出力」の一連の処理をまとめる
def run_pipeline(data, master, key, validate_relation):
    """
    param data:左表
    param master:右表
    param key:結合COLUMN
    param validate_relation:"one_to_one" / "one_to_many" / "many_to_one" / "many_to_many"
    """
    import sys
    r = {
        "status": "OK",
        "error_count": 0,
        "warning_count": 0
    }
    difference_check = data.merge(
        master,
        on=key,
        how="outer",
        validate=validate_relation,
        indicator=True
      )
    result_left_only = difference_check.loc[
        difference_check["_merge"] == "left_only",
        [key]
    ]
    result_right_only = difference_check.loc[
        difference_check["_merge"] == "right_only",
        [key]
    ]
    if not result_right_only.empty:  # ERRORとWARNINGが共に生じるケースを想定して先にWARNINGを処理
        r["status"] = "WARNING"
        r["warning_count"] = len(result_right_only)
        r["right_only"] = result_right_only
        sys.stderr.write('WARNING：売上データに存在しない商品マスタがあります。\n')
    if not result_left_only.empty:
        r["status"] = "ERROR"
        r["error_count"] = len(result_left_only)
        r["left_only"] = result_left_only
        sys.stderr.write('ERROR：商品マスタ未登録が見つかりました。\n')
    if result_left_only.empty and result_right_only.empty:
        sys.stderr.write("マスタと実データに差分はありません\n")
    try:
        if r["status"] == "ERROR":
            print("ERRORのため、後続処理を停止します。")
            return r  # ERRORならrを返して停止
        else:
            for k, v in r.items():
                print(k, v)
            transformed_data = data.merge(
                master,
                on=key,
                how="left",
                validate=validate_relation
            )  # データ加工（今回は売上データに商品マスタを結合して商品名・仕入先を付けるという処理）
            transformed_data.to_csv(
                "transformed_data.csv",
                index=False
            )
            print("下記データが出力されました。")
            return transformed_data
    except:
        print(sys.exc_info())

run_pipeline(df, product_master, "product", "many_to_one")  # ERRORが出る版での試行
  # → 下記実行結果
    # WARNING：売上データに存在しない商品マスタがあります。
    # ERROR：商品マスタ未登録が見つかりました。
    # ERRORのため、後続処理を停止します。
    # {'status': 'ERROR', 'error_count': 1, 'warning_count': 1, 'right_only': product
    #  6       W, 'left_only': product
    #  5       D}

run_pipeline(clean_df, product_master, "product", "many_to_many")  # ERRORが出ない版での試行
  # → 下記実行結果
    # WARNING：売上データに存在しない商品マスタがあります。
    # status WARNING
    # error_count 0
    # warning_count 1
    # right_only   product
    # 4       W
    # 下記データが出力されました。
    #         date product  sales_amount product_name supplier
    # 0  2026-08-1       A        120000         商品A       X社
    # 1  2026-08-2       A        120000         商品A       X社
    # 2  2026-08-3       B         80000         商品B       Y社
    # 3  2026-08-1       C         50000         商品C       Z社





