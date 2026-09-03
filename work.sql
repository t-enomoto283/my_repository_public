-- NLS_DATE_FORMAT（&置換変数）
SELECT * FROM NLS_SESSION_PARAMETERS WHERE PARAMETER = '&FORMAT';
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';


-- 顧客マスタを外部表から取り込む
CREATE TABLE admin_e(
    店舗id VARCHAR(20),
    店舗名 VARCHAR2(200),
    店舗url VARCHAR2(200),
    店舗グループ VARCHAR2(200),
    契約プラン VARCHAR2(20),
    優良区分 CHAR(4),
    大エリア VARCHAR2(20),
    都道府県 VARCHAR2(20),
    出発エリア VARCHAR2(100),
    業態 VARCHAR2(100)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'admin_e.bad'
        LOGFILE 'admin_e.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            店舗id CHAR(20),
            店舗名 CHAR(200),
            店舗url CHAR(200),
            店舗グループ CHAR(200),
            契約プラン CHAR(20),
            優良区分 CHAR(4),
            大エリア CHAR(20),
            都道府県 CHAR(20),
            出発エリア CHAR(100),
            業態 CHAR(100)
            )
        )
    LOCATION ('admin_e.csv')
    )
    REJECT LIMIT UNLIMITED
;

create table admin_e_202605 as select * from admin_e;
drop table admin_e;

-- 顧客マスタに、サイト流入やCVのデータと結合させるshop_id列を追加
ALTER TABLE admin_e_202605
  ADD shop_id VARCHAR2(20)
;

-- 顧客マスタのshop_id列を顧客マスタ内の店舗url末尾から付与
UPDATE admin_e_202605
  SET shop_id = TRIM(TRAILING '/' FROM SUBSTR(店舗url, INSTR(店舗url, 'p', 6, 2)+2, INSTR(店舗url, '/', INSTR(店舗url, 'p', 6, 2)+2)))
;

/*サイトAやBのCVデータを外部表から取り込む*/
CREATE TABLE notebook_cv(
    shop_id VARCHAR2(20),
    shop_name VARCHAR2(200),
    shop_area VARCHAR(75),
    shop_biz VARCHAR2(75),
    ランディング VARCHAR2(300),
    cv NUMBER(4)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'notebook_cv.bad'
        LOGFILE 'notebook_cv.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            shop_id CHAR(20),
            shop_name CHAR(200),
            shop_area CHAR(75),
            shop_biz CHAR(75),
            ランディング CHAR(300),
            cv FLOAT EXTERNAL
            )
        )
    LOCATION ('notebook_cv_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from notebook_cv;
create table notebook_cv_202605 as select * from notebook_cv;
select * from notebook_cv_202605;
drop table notebook_cv purge;


-- サイトAやBのCV合算用テーブル
CREATE TABLE total_cv_202605(
  shop_id VARCHAR2(10),
  shop_name VARCHAR2(200),
  shop_area VARCHAR2(200),
  shop_biz VARCHAR2(100),
  ランディング VARCHAR2(400),
  cv NUMBER(5)
);

-- CV合算テーブルにサイトAやBの値をinsert
INSERT ALL
  INTO total_cv_202605 VALUES(
    shop_id,
    shop_name,
    shop_area,
    shop_biz,
    ランディング,
    cv
    )
SELECT shop_id, shop_name, shop_area, shop_biz, ランディング, cv FROM notebook_cv_202605
;


-- サイト合算cv_業種別（特定LP除外）
SELECT
  (SELECT SUM(tap) FROM total_cv_202605 WHERE shop_biz = '業種a' AND ランディング NOT LIKE '/xxx%') "業種a",
  (SELECT SUM(tap) FROM total_cv_202605 WHERE shop_biz = '業種b' AND ランディング NOT LIKE '/yyy%') "業種b"
FROM dual
;

-- 顧客契約プラン別_cv数（特定LP除外）
SELECT
  SUM(CASE WHEN a.契約プラン = 'Sプラン' THEN s.cv ELSE 0 END) AS "Sプラン",
  SUM(CASE WHEN a.契約プラン = 'Aプラン' THEN s.cv ELSE 0 END) AS "Aプラン",
  SUM(CASE WHEN a.契約プラン IN ('Bプラン', 'Cプラン') THEN s.cv ELSE 0 END) AS "B/Cプラン",
  SUM(CASE WHEN a.契約プラン IN ('Eプラン（B）', 'Eプラン（A）', 'Eプラン（C）', 'Eプラン（D）', '無料') THEN s.cv ELSE 0 END) AS "E/無料プラン",
  SUM(CASE WHEN a.shop_id IS NULL THEN s.cv ELSE 0 END) AS "顧客マスタ未登録"
FROM (
    SELECT shop_id, SUM(cv) "CV"
    FROM total_cv_202605
      WHERE ランディング NOT LIKE '/xxx%'
    GROUP BY shop_id
) s
LEFT JOIN admin_e_202605 a
ON s.shop_id = a.shop_id
;


-- サイト合算CV_地方別_契約店一覧（特定LP除外）
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.cv),
  a.契約プラン
FROM total_cv_202605 s INNER JOIN admin_e_202605 a
ON s.shop_id = a.shop_id
  WHERE a.都道府県 = '北海道'
  AND s.ランディング NOT LIKE '/xxx%'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC;


/*特定LP別_顧客合計CV*/
WITH base AS (
  SELECT
    s.shop_name,
    s.shop_area,
    s.shop_biz,
    a.契約プラン,
    s.ランディング,
    SUM(s.cv) "landing_tap"
  FROM total_cv_202605 s
  INNER JOIN admin_e_202605 a
    ON s.shop_id = a.shop_id
  WHERE s.ランディング LIKE '/aaaa%'
  GROUP BY
    s.shop_name,
    s.shop_area,
    s.shop_biz,
    a.契約プラン,
    s.ランディング
),
ranked AS (
  SELECT
    shop_name,
    shop_area,
    shop_biz,
    契約プラン,
    ランディング,
    landing_tap,
    SUM(landing_tap) OVER (
      PARTITION BY shop_name, shop_area, shop_biz, 契約プラン
    ) "店舗合計CV",
    ROW_NUMBER() OVER (
      PARTITION BY shop_name, shop_area, shop_biz, 契約プラン
      ORDER BY landing_tap DESC, ランディング
    ) AS rn
  FROM base
)
SELECT
  ROW_NUMBER() OVER (
    ORDER BY
      店舗合計CV DESC,
      shop_name,
      shop_area,
      shop_biz,
      契約プラン
  ) AS num,
  shop_name "店舗",
  shop_area "エリア",
  shop_biz "業種",
  契約プラン "プラン",
  店舗合計CV "CV数",
  'https://aaaa-bbb.cc' || ランディング AS 代表的なランディング元
FROM ranked
WHERE rn = 1
ORDER BY
  店舗合計CV DESC,
  shop_name,
  shop_area,
  shop_biz,
  契約プラン
;






-- サイト掲載口コミの分析
/*サーチコンソールインデックス済のreviewページ*/
CREATE TABLE index_review_page(
    index_review_urls VARCHAR2(500),
    last_crawl DATE
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'index_review_page.bad'
        LOGFILE 'index_review_page.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            index_review_urls CHAR(500),
            last_crawl CHAR DATE_FORMAT DATE MASK "YYYY-MM-DD"
            )
        )
    LOCATION ('index_review_page.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from index_review_page;
create table index_review_page_0527 as select * from index_review_page;
select * from index_review_page_0527;
drop table index_review_page purge;

select * from index_review_page_0527
where index_review_urls NOT LIKE '%?%'
  and index_review_urls NOT LIKE '%review/';


/*クロール済みインデックス未登録reviewページ*/
CREATE TABLE notindex_review_page(
    notindex_review_urls VARCHAR2(500),
    last_crawl DATE
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'notindex_review_page.bad'
        LOGFILE 'notindex_review_page.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            notindex_review_urls CHAR(500),
            last_crawl CHAR DATE_FORMAT DATE MASK "YYYY-MM-DD"
            )
        )
    LOCATION ('notindex_review_page.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from notindex_review_page;
create table notindex_review_page_0527 as select * from notindex_review_page;
select * from notindex_review_page_0527;
drop table notindex_review_page purge;

select * from notindex_review_page_0527
where notindex_review_urls NOT LIKE '%?%'
  and notindex_review_urls NOT LIKE '%review/';


/*検索パフォーマンスreviewページ_ページ*/
CREATE TABLE search_performance(
    上位のページ VARCHAR2(500),
    クリック数 NUMBER(5),
    表示回数 NUMBER(6),
    CTR NUMBER(4, 3),
    掲載順位 NUMBER(4, 2)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'search_performance.bad'
        LOGFILE 'search_performance.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            上位のページ CHAR(500),
            クリック数 FLOAT EXTERNAL,
            表示回数 FLOAT EXTERNAL,
            CTR FLOAT EXTERNAL,
            掲載順位 FLOAT EXTERNAL
            )
        )
    LOCATION ('search_performance.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from search_performance;
create table search_performance_0527 as select * from search_performance;
select * from search_performance_0527;
drop table search_performance purge;

select * from search_performance_0527
where 上位のページ NOT LIKE '%?%'
  and 上位のページ NOT LIKE '%review/';


/*reviewページ_エンゲージメント*/
CREATE TABLE review_page_engagement(
    ページロケーション VARCHAR2(500),
    セッションあたりの平均エンゲージメント時間 NUMBER,
    セッション NUMBER(7),
    ユーザーあたりの平均イベント数 NUMBER
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'review_page_engagement.bad'
        LOGFILE 'review_page_engagement.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            ページロケーション CHAR(500),
            セッションあたりの平均エンゲージメント時間 FLOAT EXTERNAL,
            セッション FLOAT EXTERNAL,
            ユーザーあたりの平均イベント数 FLOAT EXTERNAL
            )
        )
    LOCATION ('review_page_engagement.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from review_page_engagement;
create table review_page_engagement_0527 as select * from review_page_engagement;
select * from review_page_engagement_0527;
drop table review_page_engagement purge;

select * from review_page_engagement_0527
where ページロケーション NOT LIKE '%?%'
  and ページロケーション NOT LIKE '%review/';



/*統合とスコア算出*/
WITH
indexed AS (
    SELECT
        REGEXP_REPLACE(TRIM(INDEX_REVIEW_URLS), '/$', '') AS review_url,
        1 AS indexed_flg,
        LAST_CRAWL AS index_last_crawl,
        CAST(NULL AS DATE) AS notindex_last_crawl
    FROM index_review_page_0527
    WHERE INDEX_REVIEW_URLS NOT LIKE '%?%'
      AND INDEX_REVIEW_URLS NOT LIKE '%review/'
),
notindexed AS (
    SELECT
        REGEXP_REPLACE(TRIM(NOTINDEX_REVIEW_URLS), '/$', '') AS review_url,
        0 AS indexed_flg,
        CAST(NULL AS DATE) AS index_last_crawl,
        LAST_CRAWL AS notindex_last_crawl
    FROM notindex_review_page_0527
    WHERE NOTINDEX_REVIEW_URLS NOT LIKE '%?%'
      AND NOTINDEX_REVIEW_URLS NOT LIKE '%review/'
),
index_base AS (
    SELECT
        review_url,
        MAX(indexed_flg) AS indexed_flg,
        MAX(index_last_crawl) AS index_last_crawl,
        MAX(notindex_last_crawl) AS notindex_last_crawl
    FROM (
        SELECT * FROM indexed
        UNION ALL
        SELECT * FROM notindexed
    )
    GROUP BY review_url
),
search_base AS (
    SELECT
        REGEXP_REPLACE(TRIM("上位のページ"), '/$', '') AS review_url,
        SUM("クリック数") AS clicks,
        SUM("表示回数") AS impressions,
        CASE
            WHEN SUM("表示回数") > 0
            THEN SUM("クリック数") / SUM("表示回数")
            ELSE NULL
        END AS ctr,
        CASE
            WHEN SUM("表示回数") > 0
            THEN SUM("掲載順位" * "表示回数") / SUM("表示回数")
            ELSE NULL
        END AS avg_position
    FROM search_performance_0527
    WHERE "上位のページ" NOT LIKE '%?%'
      AND "上位のページ" NOT LIKE '%review/'
    GROUP BY REGEXP_REPLACE(TRIM("上位のページ"), '/$', '')
),
engagement_base AS (
    SELECT
        REGEXP_REPLACE(TRIM("ページロケーション"), '/$', '') AS review_url,
        AVG("セッションあたりの平均エンゲージメント時間") AS avg_engagement_time,
        SUM("セッション") AS sessions,
        AVG("ユーザーあたりの平均イベント数") AS events_per_user
    FROM review_page_engagement_0527
    WHERE "ページロケーション" NOT LIKE '%?%'
      AND "ページロケーション" NOT LIKE '%review/'
    GROUP BY REGEXP_REPLACE(TRIM("ページロケーション"), '/$', '')
),
merged AS (
    SELECT
        i.review_url,
        i.indexed_flg,
        i.index_last_crawl,
        i.notindex_last_crawl,
        CASE WHEN s.review_url IS NOT NULL THEN 1 ELSE 0 END AS has_search_data,
        CASE WHEN e.review_url IS NOT NULL THEN 1 ELSE 0 END AS has_engagement_data,
        NVL(s.clicks, 0) AS clicks,
        NVL(s.impressions, 0) AS impressions,
        s.ctr,
        s.avg_position,
        NVL(e.avg_engagement_time, 0) AS avg_engagement_time,
        NVL(e.sessions, 0) AS sessions,
        NVL(e.events_per_user, 0) AS events_per_user
    FROM index_base i
    LEFT JOIN search_base s
        ON i.review_url = s.review_url
    LEFT JOIN engagement_base e
        ON i.review_url = e.review_url
),
ranked AS (
    SELECT
        merged.*,
        PERCENT_RANK() OVER (
            ORDER BY avg_engagement_time
        ) AS engagement_rank,
        PERCENT_RANK() OVER (
            ORDER BY events_per_user
        ) AS event_rank
    FROM merged
),
scored AS (
    SELECT
        ranked.*,
        CASE
            WHEN indexed_flg = 1 THEN 1
            ELSE 0
        END AS index_score,
        CASE
            WHEN has_engagement_data = 1 AND engagement_rank >= 0.7 THEN 2
            WHEN has_engagement_data = 1 AND engagement_rank >= 0.5 THEN 1
            ELSE 0
        END AS engagement_score,
        CASE
            WHEN has_engagement_data = 1 AND event_rank >= 0.7 THEN 2
            WHEN has_engagement_data = 1 AND event_rank >= 0.5 THEN 1
            ELSE 0
        END AS event_score
    FROM ranked
),
final_scored AS (
    SELECT
        scored.*,
        index_score
        + engagement_score
        + event_score AS good_review_score
    FROM scored
)
SELECT
    review_url AS "口コミページURL",
    indexed_flg AS "インデックス登録フラグ",
    index_last_crawl AS "インデックス登録済_最終クロール日",
    notindex_last_crawl AS "未インデックス_最終クロール日",
    has_search_data AS "検索パフォーマンスデータ有無",
    has_engagement_data AS "GA4エンゲージメントデータ有無",
    clicks AS "検索クリック数",
    impressions AS "検索表示回数",
    ctr AS "検索クリック率",
    avg_position AS "検索平均掲載順位",
    avg_engagement_time AS "平均エンゲージメント時間",
    sessions AS "セッション数",
    events_per_user AS "ユーザーあたりの平均イベント数",
    ROUND(engagement_rank, 3) AS "エンゲージメント順位率",
    ROUND(event_rank, 3) AS "イベント順位率",
    index_score AS "インデックス評価点",
    engagement_score AS "熟読評価点",
    event_score AS "行動評価点",
    good_review_score AS "良口コミ総合スコア",
    CASE
        WHEN good_review_score >= 5 THEN '良'
        WHEN good_review_score BETWEEN 3 AND 4 THEN '中'
        ELSE '不良'
    END AS "良口コミ判定"
FROM final_scored
ORDER BY
    good_review_score DESC,
    indexed_flg DESC,
    has_engagement_data DESC,
    avg_engagement_time DESC,
    events_per_user DESC;






