

/*【実務】*/
-- 【保存する先は、work.sql 】



-- NLS_DATE_FORMAT（&置換変数）
SELECT * FROM NLS_SESSION_PARAMETERS WHERE PARAMETER = '&FORMAT';

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';





-- 禁忌たるデータベース
CREATE TABLE writer_biz(
    キーid NUMBER(6),
    担当者 VARCHAR2(150),
    実働時間 NUMBER,
    媒体 VARCHAR2(50),
    種別 VARCHAR2(150),
    作業内容 VARCHAR2(100),
    本数 NUMBER(6),
    完了日 DATE
)
ORGANIZATION EXTERNAL
(
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
    (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'writer_biz.bad'
        LOGFILE 'writer_biz.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
        (
            キーid FLOAT EXTERNAL NULLIF キーid=BLANKS,
            担当者 CHAR(150),
            実働時間 FLOAT EXTERNAL NULLIF 実働時間=BLANKS,
            媒体 CHAR(50),
            種別 CHAR(150),
            作業内容 CHAR(100),
            本数 FLOAT EXTERNAL NULLIF 本数=BLANKS,
            完了日 CHAR DATE_FORMAT DATE MASK "YYYY/MM/DD" NULLIF 完了日=BLANKS
        )
    )
    LOCATION ('writer_biz.csv')
)
REJECT LIMIT UNLIMITED
;

select * from writer_biz;
create table writer_biz_202601_202605 as select * from writer_biz;
select * from writer_biz_202601_202605;
drop table writer_biz purge;






/*記事作成本数*/
SELECT
    媒体,
    SUM(本数)
FROM writer_biz_202601_202605
    WHERE TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    -- AND 媒体 NOT IN('MTG', '社内用事', '資料作成', '新人研修', '研修', 'セミナー')
    AND 作業内容 = '本文作成'
    GROUP BY 媒体
    ORDER BY 1 ASC
    ;

SELECT 種別, SUM(本数)
    FROM writer_biz_202601_202605
    WHERE 媒体 IN ('IMC')
    AND TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    AND 作業内容 = '本文作成'
    GROUP BY 種別
    ORDER BY 1 ASC;

SELECT 種別, SUM(本数)
    FROM writer_biz_202601_202605
    WHERE 媒体 IN ('ココア', 'リラクジョブ')
    AND TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    AND 作業内容 = '本文作成'
    GROUP BY 種別
    ORDER BY 1 ASC;

SELECT 種別, SUM(本数)
    FROM writer_biz_202601_202605
    WHERE 媒体 IN ('体入エミリー')
    AND TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    AND 作業内容 = '本文作成'
    GROUP BY 種別
    ORDER BY 1 ASC;

SELECT 種別, SUM(本数)
    FROM writer_biz_202601_202605
    WHERE 媒体 IN ('体入ホスパラ', '夜遊びホスパラ', 'ホスパラ')
    AND TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    AND 作業内容 = '本文作成'
    GROUP BY 種別
    ORDER BY 1 ASC;

SELECT 種別, SUM(本数)
    FROM writer_biz_202601_202605
    WHERE 媒体 IN ('駅ちか', 'メンズリラク')
    AND TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    AND 作業内容 = '本文作成'
    GROUP BY 種別
    ORDER BY 1 ASC;







/*稼働時間*/
SELECT
    媒体,
    SUM(実働時間)
FROM writer_biz_202601_202605
    WHERE TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    AND 媒体 NOT IN('新人研修', '資料作成')
    AND 媒体 IS NOT NULL
    GROUP BY 媒体
    ORDER BY 1 ASC;

SELECT
    種別 AS "IMC-PJT",
    SUM(実働時間)
FROM writer_biz_202601_202605
    WHERE TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    AND 媒体 IN ('IMC')
    AND 種別 IS NOT NULL
    GROUP BY 種別
    ORDER BY 1 ASC;

SELECT
    種別 AS "ココア-PJT",
    SUM(実働時間)
FROM writer_biz_202601_202605
    WHERE TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    AND 媒体 IN ('ココア', 'リラクジョブ')
    AND 種別 IS NOT NULL
    GROUP BY 種別
    ORDER BY 1 ASC;

SELECT
    種別 AS "エミリ-PJT",
    SUM(実働時間)
FROM writer_biz_202601_202605
    WHERE TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    AND 媒体 IN ('体入エミリー')
    AND 種別 IS NOT NULL
    GROUP BY 種別
    ORDER BY 1 ASC;

SELECT
    種別 AS "ホスパラ-PJT",
    SUM(実働時間)
FROM writer_biz_202601_202605
    WHERE TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    AND 媒体 IN ('体入ホスパラ', 'ホスパラ')
    AND 種別 IS NOT NULL
    GROUP BY 種別
    ORDER BY 1 ASC;

SELECT
    種別 AS "駅ちか-PJT",
    SUM(実働時間)
FROM writer_biz_202601_202605
    WHERE TO_CHAR(完了日, 'YYYY/MM') LIKE '2026/05'
    AND 媒体 IN ('駅ちか', 'メンズリラク')
    AND 種別 IS NOT NULL
    GROUP BY 種別
    ORDER BY 1 ASC;











/*サマリーを作る用（駅ちか系サテライト）*/
CREATE TABLE notebook_session(
    ページロケーション VARCHAR(500),
    ページタイトル VARCHAR2(500),
    イベント数 NUMBER(7)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'notebook_session.bad'
        LOGFILE 'notebook_session.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            ページロケーション CHAR(500),
            ページタイトル CHAR(500),
            イベント数 FLOAT EXTERNAL
            )
        )
    LOCATION ('notebook_session_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from notebook_session_202605;
create table notebook_session_202605 as select * from notebook_session;
drop table notebook_session purge;

CREATE TABLE notebook_select(
    ページの参照元url VARCHAR2(300),
    ページロケーション VARCHAR2(400),
    shop_id NUMBER(8),
    shop_name VARCHAR(200),
    shop_biz VARCHAR2(100),
    イベント数 NUMBER(6)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'notebook_select.bad'
        LOGFILE 'notebook_select.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            ページの参照元url CHAR(300),
            ページロケーション CHAR(400),
            shop_id FLOAT EXTERNAL,
            shop_name CHAR(200),
            shop_biz CHAR(100),
            イベント数 FLOAT EXTERNAL
            )
        )
    LOCATION ('notebook_select_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from notebook_select_202605;
create table notebook_select_202605 as select * from notebook_select;
drop table notebook_select purge;

CREATE TABLE matome_tap(
    shop_id VARCHAR2(20),
    shop_name VARCHAR2(200),
    shop_area VARCHAR(75),
    shop_biz VARCHAR2(75),
    ランディング VARCHAR2(300),
    tap NUMBER(4)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'matome_tap.bad'
        LOGFILE 'matome_tap.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            shop_id CHAR(20),
            shop_name CHAR(200),
            shop_area CHAR(75),
            shop_biz CHAR(75),
            ランディング CHAR(300),
            tap FLOAT EXTERNAL
            )
        )
    LOCATION ('matome_tap_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from matome_tap_202605;
create table matome_tap_202605 as select * from matome_tap;
drop table matome_tap purge;

/*admin_eki_YYYYMM を作り整えた後に、menmaga_tap_YYYYMM の shop_name列 を更新する*/
MERGE INTO menmaga_tap_202605 m
  USING admin_eki_202606 a
  ON (m.shop_id = a.shop_id)
    WHEN MATCHED THEN
      UPDATE SET m.shop_name = a.店舗名
;
select * from menmaga_tap_202605;


-- 演算

-- sate_eki_tap_YYYYMM（TAP合算用テーブルを作る時）
CREATE TABLE sate_eki_tap_202605(
  shop_id VARCHAR2(10),
  shop_name VARCHAR2(200),
  shop_area VARCHAR2(200),
  shop_biz VARCHAR2(100),
  ランディング VARCHAR2(400),
  tap NUMBER(5)
);

INSERT ALL
  INTO sate_eki_tap_202605 VALUES(
    shop_id,
    shop_name,
    shop_area,
    shop_biz,
    ランディング,
    tap
    )
SELECT shop_id, shop_name, shop_area, shop_biz, ランディング, tap FROM notebook_tap_202605
;

-- サテライト別_TAP件数
SELECT
  (SELECT SUM(tap) FROM notebook_tap_202605) "雑記帳TAP",
  (SELECT SUM(tap) FROM matome_tap_202605) "まとめTAP",
  (SELECT SUM(tap) FROM guide_tap_202605) "ガイドTAP",
  (SELECT SUM(tap) FROM fuosu_tap_202605) "風おすTAP",
  (SELECT SUM(tap) FROM deliosu_tap_202605) "デリおすTAP",
  (SELECT SUM(tap) FROM menmaga_tap_202605) "メンマガTAP",
  (SELECT SUM(tap) FROM notebook_tap_202605) +
  (SELECT SUM(tap) FROM matome_tap_202605) +
  (SELECT SUM(tap) FROM guide_tap_202605) +
  (SELECT SUM(tap) FROM fuosu_tap_202605) +
  (SELECT SUM(tap) FROM deliosu_tap_202605) +
  (SELECT SUM(tap) FROM menmaga_tap_202605) "合算TAP"  
FROM dual
;
*/

-- 業種別用_TAP件数（ガイド除外）
SELECT
  (SELECT SUM(tap) FROM sate_eki_tap_202509 WHERE shop_biz = 'デリヘル' AND ランディング NOT LIKE '/guide%') AS "デリヘル",
  (SELECT SUM(tap) FROM sate_eki_tap_202509 WHERE shop_biz = 'ヘルス' AND ランディング NOT LIKE '/guide%') AS "ヘルス",
  (SELECT SUM(tap) FROM sate_eki_tap_202509 WHERE shop_biz = 'ソープ' AND ランディング NOT LIKE '/guide%') AS "ソープ",
  (SELECT SUM(tap) FROM sate_eki_tap_202509 WHERE shop_biz = 'ホテヘル' AND ランディング NOT LIKE '/guide%') AS "ホテヘル",
  (SELECT SUM(tap) FROM sate_eki_tap_202509 WHERE shop_biz = '風俗エステ' AND ランディング NOT LIKE '/guide%') AS "風俗エステ",
  (SELECT SUM(tap) FROM sate_eki_tap_202509 WHERE shop_biz = 'メンズエステ' AND ランディング NOT LIKE '/guide%') AS "メンズエステ",
  (SELECT SUM(tap) FROM sate_eki_tap_202509 WHERE shop_biz = 'ピンサロ' AND ランディング NOT LIKE '/guide%') AS "ピンサロ"
FROM dual
;

-- 基本プラン別用_TAP件数（ガイド除外）
SELECT
  SUM(CASE WHEN a.契約プラン = 'Sプラン' THEN s.tap ELSE 0 END) AS "Sプラン",
  SUM(CASE WHEN a.契約プラン = 'Aプラン' THEN s.tap ELSE 0 END) AS "Aプラン",
  SUM(CASE WHEN a.契約プラン IN ('Bプラン', 'Cプラン') THEN s.tap ELSE 0 END) AS "B/Cプラン",
  SUM(CASE WHEN a.契約プラン IN ('Eプラン（B）', 'Eプラン（A）', 'Eプラン（C）', 'Eプラン（D）', '無料') THEN s.tap ELSE 0 END) AS "E/無料プラン",
  SUM(CASE WHEN a.shop_id IS NULL THEN s.tap ELSE 0 END) AS "admin未登録"
FROM (
    SELECT shop_id, SUM(tap) tap
    FROM sate_eki_tap_202605
      WHERE ランディング NOT LIKE '/guide%'
    GROUP BY shop_id
) s
LEFT JOIN admin_eki_202606 a
ON s.shop_id = a.shop_id
;

-- 優良区分別用（ガイド除外）
SELECT
  SUM(CASE WHEN a.優良区分 IN ('6', '5', '4') THEN s.tap END) AS "優良店区分：6～4",
  SUM(CASE WHEN a.優良区分 = '3' THEN s.tap END) AS "優良店区分：3",
  SUM(CASE WHEN a.優良区分 IN ('2', '1', '-') THEN s.tap END) AS "優良区分3未満"
FROM sate_eki_tap_202509 s INNER JOIN admin_eki_202509 a
ON s.shop_id = a.shop_id
  WHERE s.ランディング NOT LIKE '/guide%'
;
*/


-- sate_eki_session_YYYYMM（セッション合算用テーブルを作る時）

CREATE TABLE sate_eki_session_202605(
  ページロケーション VARCHAR2(400),
  ページタイトル VARCHAR2(500),
  イベント数 NUMBER(7)
  )
;

INSERT ALL
  INTO sate_eki_session_202605 VALUES(
    ページロケーション,
    ページタイトル,
    イベント数
    )
SELECT ページロケーション, ページタイトル, イベント数 FROM notebook_session_202605
;

-- サテライト別_セッション数
SELECT
  (SELECT SUM(イベント数) FROM notebook_session_202605) "雑記帳セッション",
  (SELECT SUM(イベント数) FROM matome_session_202605) "まとめセッション",
  (SELECT SUM(イベント数) FROM guide_session_202605) "ガイドセッション",
  (SELECT SUM(イベント数) FROM fuosu_session_202605) "風おすセッション",
  (SELECT SUM(イベント数) FROM deliosu_session_202605) "デリおすセッション",
  (SELECT SUM(イベント数) FROM menmaga_session_202605) "メンマガセッション",
  (SELECT SUM(イベント数) FROM notebook_session_202605) +
  (SELECT SUM(イベント数) FROM matome_session_202605) +
  (SELECT SUM(イベント数) FROM guide_session_202605) +
  (SELECT SUM(イベント数) FROM fuosu_session_202605) +
  (SELECT SUM(イベント数) FROM deliosu_session_202605) +
  (SELECT SUM(イベント数) FROM menmaga_session_202605) "合算セッション"  
FROM dual
;
*/



-- sate_eki_select_YYYYMM（送客合算用テーブルを作る時）

CREATE TABLE sate_eki_select_202605(
  ページの参照元url VARCHAR2(400),
  イベント数 NUMBER(7)
  )
;

DESCRIBE fuosu_select_202605;
DESCRIBE menmaga_select_202605;

ALTER TABLE fuosu_select_202605
  RENAME COLUMN ページロケーション TO ページの参照元url
;

INSERT ALL
  INTO sate_eki_select_202605 VALUES(
    ページの参照元url,
    イベント数
    )
SELECT ページの参照元url, イベント数 FROM notebook_select_202605
;

-- サテライト別_送客数
SELECT
  (SELECT SUM(イベント数) FROM notebook_select_202605) "雑記帳-送客",
  (SELECT SUM(イベント数) FROM matome_select_202605) "まとめ-送客",
  (SELECT SUM(イベント数) FROM guide_select_202605) "ガイド-送客",
  (SELECT SUM(イベント数) FROM fuosu_select_202605) "風おす-送客",
  (SELECT SUM(イベント数) FROM deliosu_select_202605) "デリおす-送客",
  (SELECT SUM(イベント数) FROM menmaga_select_202605) "メンマガ-送客",
  (SELECT SUM(イベント数) FROM notebook_select_202605) +
  (SELECT SUM(イベント数) FROM matome_select_202605) +
  (SELECT SUM(イベント数) FROM guide_select_202605) +
  (SELECT SUM(イベント数) FROM fuosu_select_202605) +
  (SELECT SUM(イベント数) FROM deliosu_select_202605) +
  (SELECT SUM(イベント数) FROM menmaga_select_202605) "合算送客"  
FROM dual
;
*/



-- サテライト合算_地方別_店舗一覧（ガイド除外）
/*大エリア*/
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン,
  a.優良区分
FROM sate_eki_tap_202605 s INNER JOIN admin_eki_202606 a
ON s.shop_id = a.shop_id
  WHERE a.大エリア = '九州・沖縄'
  AND s.ランディング NOT LIKE '/guide%'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン, a.優良区分
ORDER BY 4 DESC
;

/*支社レベル*/
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン
FROM sate_eki_tap_202605 s INNER JOIN admin_eki_202606 a
ON s.shop_id = a.shop_id
  WHERE a.都道府県 = '北海道'
  AND s.ランディング NOT LIKE '/guide%'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC;

SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン
FROM sate_eki_tap_202605 s INNER JOIN admin_eki_202606 a
ON s.shop_id = a.shop_id
  WHERE a.都道府県 IN ('熊本県', '宮崎県', '鹿児島県', '沖縄県')
  AND s.ランディング NOT LIKE '/guide%'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC;


-- 西日本【エリア会議のスライド通る時は '/guide%' も含ませる】
SELECT
  a.大エリア,
  SUM(s.tap)
FROM sate_eki_tap_202605 s INNER JOIN admin_eki_202606 a
ON s.shop_id = a.shop_id
  WHERE s.ランディング NOT LIKE '/guide%'
  AND a.大エリア IN ('関西', '中国・四国', '九州・沖縄')
GROUP BY a.大エリア
;

-- 東日本【エリア会議のスライド通る時は '/guide%' も含ませる】
SELECT
  a.大エリア,
  SUM(s.tap)
FROM sate_eki_tap_202605 s INNER JOIN admin_eki_202606 a
ON s.shop_id = a.shop_id
  WHERE s.ランディング NOT LIKE '/guide%'
  AND a.大エリア IN ('北海道・東北', '関東', '中部')
GROUP BY a.大エリア
;


-- サテライト合算_業種別_店舗一覧（ガイド除外）
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン,
  a.優良区分
FROM sate_eki_tap_202601 s INNER JOIN admin_eki_202601 a
ON s.shop_id = a.shop_id
  WHERE s.shop_biz = 'デリヘル'
  AND s.ランディング NOT LIKE '/guide%'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン, a.優良区分
ORDER BY 4 DESC
;

-- 記事別用_店舗一覧
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  s.tap,
  s.ランディング,
  a.契約プラン,
  a.優良区分
FROM sate_eki_tap_202604 s INNER JOIN admin_eki_202605 a
ON s.shop_id = a.shop_id
  -- WHERE 大エリア IN ('中部')
  -- WHERE 大エリア IN ('北海道・東北', '関東', '中部')
  WHERE s.shop_name LIKE 'THE ESUTE五反田%'
  -- AND s.ランディング NOT LIKE '/guide%'
  -- AND s.ランディング LIKE '/guide%'
  -- AND s.ランディング LIKE '/matome%'
ORDER BY 4 DESC
;

select
  s.shop_name,
  sum(s.tap),
  s.shop_area,
  a.都道府県,
  s.ランディング,
  a.契約プラン
from sate_eki_tap_202604 s INNER JOIN admin_eki_202605 a
ON s.shop_id = a.shop_id
  WHERE 大エリア IN ('中国・四国')
  -- WHERE s.shop_name LIKE '美少女制服学園CLASSMATE%'
  AND s.ランディング NOT LIKE '/guide%'
group by s.shop_name, s.shop_area, a.都道府県, s.ランディング, a.契約プラン
order by 2 desc
;
select 大エリア from admin_eki_202604 group by 大エリア;


-- admin_eki_YYYYMM を作る用

CREATE TABLE admin_eki(
    店舗id VARCHAR(20),
    店舗名 VARCHAR2(200),
    店舗url VARCHAR2(200),
    店舗グループ VARCHAR2(200),
    契約プラン VARCHAR2(20),
    優良区分 CHAR(4),
    大エリア VARCHAR2(20),
    都道府県 VARCHAR2(20),
    出発エリア VARCHAR2(100),
    業態 VARCHAR2(100),
    電話タップ数 NUMBER(8)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'admin_eki.bad'
        LOGFILE 'admin_eki.log'
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
            業態 CHAR(100),
            電話タップ数 FLOAT EXTERNAL
            )
        )
    LOCATION ('admin_eki_202606.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from admin_eki_202606;
create table admin_eki_202606 as select * from admin_eki;
drop table admin_eki purge;

-- admin_eki_YYYYMM に shop_id 列を追加する用
ALTER TABLE admin_eki_202606
  ADD shop_id VARCHAR2(20)
;

UPDATE admin_eki_202606
  SET shop_id = TRIM(TRAILING '/' FROM SUBSTR(店舗url, INSTR(店舗url, 'p', 6, 2)+2, INSTR(店舗url, '/', INSTR(店舗url, 'p', 6, 2)+2)))
;

-- 契約プランの変化を見る用
SELECT
  a.店舗名,
  a.契約プラン,
  NULLIF(a.契約プラン, b.契約プラン),
  b.契約プラン
FROM admin_eki_202602 a FULL OUTER JOIN admin_eki_202603 b
ON a.shop_id = b.shop_id
  WHERE NULLIF(a.契約プラン, b.契約プラン) IS NOT NULL
;
*/






/*サマリーを作る用（ホスパラ系サテライト）*/
CREATE TABLE hosumiru_select(
    ページロケーション VARCHAR(400),
    ページタイトル VARCHAR2(500),
    イベント数 NUMBER(7)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'hosumiru_select.bad'
        LOGFILE 'hosumiru_select.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            ページロケーション CHAR(400),
            ページタイトル CHAR(500),
            イベント数 FLOAT EXTERNAL
            )
        )
    LOCATION ('hosumiru_select_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from hosumiru_select_202605;
create table hosumiru_select_202605 as select * from hosumiru_select;
drop table hosumiru_select purge;

CREATE TABLE hosumiru_tap(
    shop_id VARCHAR2(20),
    shop_name VARCHAR2(200),
    shop_area VARCHAR(75),
    shop_biz VARCHAR2(75),
    ランディング VARCHAR2(100),
    tap NUMBER(4)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'hosumiru_tap.bad'
        LOGFILE 'hosumiru_tap.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            shop_id CHAR(20),
            shop_name CHAR(200),
            shop_area CHAR(75),
            shop_biz CHAR(75),
            ランディング CHAR(100),
            tap FLOAT EXTERNAL
            )
        )
    LOCATION ('hosumiru_tap_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from hosumiru_tap_202605;
create table hosumiru_tap_202605 as select * from hosumiru_tap;
drop table hosumiru_tap purge;

UPDATE hosunavi_tap_202605
  SET shop_id = LPAD(shop_id, LENGTH(shop_id)+1, 't')
;



-- 演算

-- sate_hosu_tap_YYYYMM（TAP合算用テーブルを作る時）
CREATE TABLE sate_hosu_tap_202605(
  shop_id VARCHAR2(10),
  shop_name VARCHAR2(200),
  shop_area VARCHAR2(200),
  shop_biz VARCHAR2(100),
  ランディング VARCHAR2(400),
  tap NUMBER(5)
  )
;

INSERT ALL
  INTO sate_hosu_tap_202605 VALUES(
    shop_id,
    shop_name,
    shop_area,
    shop_biz,
    ランディング,
    tap
    )
SELECT shop_id, shop_name, shop_area, shop_biz, ランディング, tap FROM hosumiru_tap_202605
;

-- サテライト別_TAP件数
SELECT
  (SELECT SUM(tap) FROM hosunavi_tap_202605) "ホスパラnaviTAP",
  (SELECT SUM(tap) FROM hosumiru_tap_202605) "ホスミルTAP",
  (SELECT SUM(tap) FROM hosunavi_tap_202605) +
  (SELECT SUM(tap) FROM hosumiru_tap_202605) "合算TAP"  
FROM dual
;
*/

-- 業種別用_TAP件数
SELECT
  (SELECT SUM(tap) FROM sate_hosu_tap_202603 WHERE shop_biz = 'ホストクラブ') AS "ホストクラブ",
  (SELECT SUM(tap) FROM sate_hosu_tap_202603 WHERE shop_biz = 'ボーイズバー') AS "ボーイズバー",
  (SELECT SUM(tap) FROM sate_hosu_tap_202603 WHERE shop_biz = 'メンズコンカフェ') AS "メンズコンカフェ"
FROM dual
;

-- 基本プラン別用_TAP件数
SELECT
  SUM(CASE WHEN a.契約プラン = 'Aプラン' THEN s.tap ELSE 0 END) AS "Aプラン",
  SUM(CASE WHEN a.契約プラン = 'Bプラン' THEN s.tap ELSE 0 END) AS "Bプラン",
  SUM(CASE WHEN a.契約プラン = 'Eプラン' THEN s.tap ELSE 0 END) AS "Eプラン",
  SUM(CASE WHEN a.shop_id IS NULL THEN s.tap ELSE 0 END) AS "admin未登録"
FROM (
    SELECT shop_id, SUM(tap) tap
    FROM sate_hosu_tap_202605
    GROUP BY shop_id
) s
LEFT JOIN admin_hosu_202606 a
ON s.shop_id = a.shop_id
;


-- sate_hosu_session_YYYYMM（セッション合算用テーブルを作る時）
CREATE TABLE sate_hosu_session_202605(
  ページロケーション VARCHAR2(400),
  ページタイトル VARCHAR2(500),
  イベント数 NUMBER(7)
  )
;

INSERT ALL
  INTO sate_hosu_session_202605
    VALUES(
      ページロケーション,
      ページタイトル,
      イベント数
    )
SELECT ページロケーション, ページタイトル, イベント数 FROM hosumiru_session_202605
;

-- サテライト別_セッション数
SELECT
  (SELECT SUM(イベント数) FROM hosunavi_session_202605) "ホスパラnaviセッション",
  (SELECT SUM(イベント数) FROM hosumiru_session_202605) "ホスミルセッション",
  (SELECT SUM(イベント数) FROM hosunavi_session_202605) +
  (SELECT SUM(イベント数) FROM hosumiru_session_202605) "合算セッション"  
FROM dual
;
*/


-- sate_hosu_select_YYYYMM（送客合算用テーブルを作る時）
CREATE TABLE sate_hosu_select_202605(
  ページロケーション VARCHAR2(400),
  イベント数 NUMBER(7)
  )
;

INSERT ALL
  INTO sate_hosu_select_202605
    VALUES(
      ページロケーション,
      イベント数
    )
SELECT ページロケーション, イベント数 FROM hosumiru_select_202605
;

-- サテライト別_送客数
SELECT
  (SELECT SUM(イベント数) FROM hosunavi_select_202605) "ホスパラnavi-送客",
  (SELECT SUM(イベント数) FROM hosumiru_select_202605) "ホスミル-送客",
  (SELECT SUM(イベント数) FROM hosunavi_select_202605) +
  (SELECT SUM(イベント数) FROM hosumiru_select_202605) "合算送客"  
FROM dual
;
*/



-- サテライト合算_地方別_店舗一覧
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(CASE WHEN s.shop_id LIKE '%t%' THEN s.tap ELSE 0 END) AS "体入ホスパラTAP",
  SUM(CASE WHEN s.shop_id NOT LIKE '%t%' THEN s.tap ELSE 0 END) AS "ホスパラTAP",
  a.契約プラン,
  SUM(s.tap) AS "TAP合計"
FROM sate_hosu_tap_202605 s INNER JOIN admin_hosu_202606 a
ON s.shop_id = a.shop_id
  WHERE a.大エリア = '九州・沖縄'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 7 DESC
;

/*支社レベル*/
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(CASE WHEN s.shop_id LIKE '%t%' THEN s.tap ELSE 0 END) AS "体入ホスパラTAP",
  SUM(CASE WHEN s.shop_id NOT LIKE '%t%' THEN s.tap ELSE 0 END) AS "ホスパラTAP",
  a.契約プラン
FROM sate_hosu_tap_202605 s INNER JOIN admin_hosu_202606 a
ON s.shop_id = a.shop_id
  WHERE a.都道府県 = '北海道'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC;

SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(CASE WHEN s.shop_id LIKE '%t%' THEN s.tap ELSE 0 END) AS "体入ホスパラTAP",
  SUM(CASE WHEN s.shop_id NOT LIKE '%t%' THEN s.tap ELSE 0 END) AS "ホスパラTAP",
  a.契約プラン
FROM sate_hosu_tap_202605 s INNER JOIN admin_hosu_202606 a
ON s.shop_id = a.shop_id
  WHERE a.都道府県 IN ('熊本県', '宮崎県', '鹿児島県', '沖縄県')
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC;

-- 西日本
SELECT
  a.大エリア,
  SUM(s.tap)
FROM sate_hosu_tap_202605 s INNER JOIN admin_hosu_202606 a
ON s.shop_id = a.shop_id
  WHERE a.大エリア IN ('関西', '中国・四国', '九州・沖縄')
GROUP BY a.大エリア
;

-- 東日本
SELECT
  a.大エリア,
  SUM(s.tap)
FROM sate_hosu_tap_202605 s INNER JOIN admin_hosu_202606 a
ON s.shop_id = a.shop_id
  WHERE a.大エリア IN ('北海道・東北', '関東', '北陸・甲信越', '東海')
GROUP BY a.大エリア
;



-- サテライト合算_業種別_店舗一覧
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(CASE WHEN s.shop_id LIKE '%t%' THEN s.tap ELSE 0 END) AS "体入ホスパラTAP",
  SUM(CASE WHEN s.shop_id NOT LIKE '%t%' THEN s.tap ELSE 0 END) AS "ホスパラTAP",
  a.契約プラン,
  SUM(s.tap) AS "TAP合計"
FROM sate_hosu_tap_202602 s INNER JOIN admin_hosu_202602 a
ON s.shop_id = a.shop_id
  WHERE s.shop_biz = 'ボーイズバー'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 7 DESC
;

-- 記事別用_店舗一覧
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  a.契約プラン,
  SUM(CASE WHEN s.shop_id LIKE '%t%' THEN s.tap ELSE 0 END) AS "体入ホスパラTAP",
  SUM(CASE WHEN s.shop_id NOT LIKE '%t%' THEN s.tap ELSE 0 END) AS "ホスパラTAP",
  SUM(s.tap) AS "TAP合計",
  s.ランディング
FROM sate_hosu_tap_202605 s INNER JOIN admin_hosu_202606 a
ON s.shop_id = a.shop_id
  WHERE s.shop_name LIKE 'No.9 SAPPORO by ACQUA%'
  -- WHERE 大エリア IN ('関東')
  -- WHERE a.大エリア IN ('北海道・東北', '関東', '中部')
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン, s.ランディング
ORDER BY 7 DESC
;



-- admin_taiho_YYYYMM を作る用
CREATE TABLE admin_taiho(
    ログインid VARCHAR(30),
    店舗名 VARCHAR2(200),
    店舗url VARCHAR2(200),
    店舗グループ VARCHAR2(200),
    契約プラン VARCHAR2(20),
    大エリア VARCHAR2(20),
    都道府県 VARCHAR2(20),
    出発エリア VARCHAR2(100),
    業種 VARCHAR2(100),
    総合タップ数 NUMBER(8)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'admin_taiho.bad'
        LOGFILE 'admin_taiho.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            ログインid CHAR(30),
            店舗名 CHAR(200),
            店舗url CHAR(200),
            店舗グループ CHAR(200),
            契約プラン CHAR(20),
            大エリア CHAR(20),
            都道府県 CHAR(20),
            出発エリア CHAR(100),
            業種 CHAR(100),
            総合タップ数 FLOAT EXTERNAL
            )
        )
    LOCATION ('admin_taiho_202606.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from admin_taiho_202606;
create table admin_taiho_202606 as select * from admin_taiho;
drop table admin_taiho purge;

-- admin_taiho_YYYYMM に shop_id 列を追加して 先頭に t を付与する用
ALTER TABLE admin_taiho_202606
  ADD shop_id VARCHAR2(20)
;

UPDATE admin_taiho_202606
  SET shop_id = 't' || REGEXP_REPLACE(店舗url, '.*/([0-9]+)/?$', '\1')
;


-- admin_hosupara_YYYYMM を作る用
CREATE TABLE admin_hosupa(
    ログインid VARCHAR(30),
    店舗名 VARCHAR2(200),
    店舗url VARCHAR2(200),
    店舗グループ VARCHAR2(200),
    契約プラン VARCHAR2(20),
    大エリア VARCHAR2(20),
    都道府県 VARCHAR2(20),
    出発エリア VARCHAR2(100),
    業種 VARCHAR2(100),
    総合タップ数 NUMBER(8)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'admin_hosupa.bad'
        LOGFILE 'admin_hosupa.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            ログインid CHAR(30),
            店舗名 CHAR(200),
            店舗url CHAR(200),
            店舗グループ CHAR(200),
            契約プラン CHAR(20),
            大エリア CHAR(20),
            都道府県 CHAR(20),
            出発エリア CHAR(100),
            業種 CHAR(100),
            総合タップ数 FLOAT EXTERNAL
            )
        )
    LOCATION ('admin_hosupa_202606.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from admin_hosupa_202606;
create table admin_hosupa_202606 as select * from admin_hosupa;
drop table admin_hosupa purge;

-- admin_hosupa_YYYYMM に shop_id 列を追加する用
ALTER TABLE admin_hosupa_202606
  ADD shop_id VARCHAR2(20)
;

UPDATE admin_hosupa_202606
  SET shop_id = TRIM(BOTH '/' FROM SUBSTR(店舗url, INSTR(店舗url, '/', 9, 3), INSTR(店舗url, '/', 9, 4)))
;


-- admin_taiho_YYYYMM と admin_hosupa_YYYYMM を統合する用
CREATE TABLE admin_hosu_202606(
  ログインid VARCHAR(30),
  店舗名 VARCHAR2(200),
  店舗url VARCHAR2(200),
  店舗グループ VARCHAR2(200),
  契約プラン VARCHAR2(20),
  大エリア VARCHAR2(20),
  都道府県 VARCHAR2(20),
  出発エリア VARCHAR2(100),
  業種 VARCHAR2(100),
  総合タップ数 NUMBER(8),
  shop_id VARCHAR2(20)
  )
;
select * from admin_hosu_202606;
INSERT ALL
  INTO admin_hosu_202606 VALUES(
    ログインid,
    店舗名,
    店舗url,
    店舗グループ,
    契約プラン,
    大エリア,
    都道府県,
    出発エリア,
    業種,
    総合タップ数,
    shop_id
    )
SELECT
  ログインid,
  店舗名,
  店舗url,
  店舗グループ,
  契約プラン,
  大エリア,
  都道府県,
  出発エリア,
  業種,
  総合タップ数,
  shop_id
FROM admin_hosupa_202606
;
*/






/*サマリーを作る用（ココア系サテライト）*/
CREATE TABLE riramaga_select(
    ページロケーション VARCHAR(400),
    ページタイトル VARCHAR2(500),
    イベント数 NUMBER(7)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'riramaga_select.bad'
        LOGFILE 'riramaga_select.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            ページロケーション CHAR(400),
            ページタイトル CHAR(500),
            イベント数 FLOAT EXTERNAL
            )
        )
    LOCATION ('riramaga_select_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from riramaga_select_202605;
create table riramaga_select_202605 as select * from riramaga_select;
drop table riramaga_select purge;

CREATE TABLE riramaga_tap(
    shop_id VARCHAR2(20),
    shop_name VARCHAR2(300),
    shop_area VARCHAR(75),
    shop_biz VARCHAR2(150),
    ランディング VARCHAR2(300),
    tap NUMBER(4)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'riramaga_tap.bad'
        LOGFILE 'riramaga_tap.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            shop_id CHAR(20),
            shop_name CHAR(300),
            shop_area CHAR(75),
            shop_biz CHAR(150),
            ランディング CHAR(300),
            tap FLOAT EXTERNAL
            )
        )
    LOCATION ('riramaga_tap_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from riramaga_tap_202605;
create table riramaga_tap_202605 as select * from riramaga_tap;
drop table riramaga_tap purge;


CREATE TABLE joshimiru_select(
    ページロケーション VARCHAR(400),
    ページタイトル VARCHAR2(500),
    イベント数 NUMBER(7)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'joshimiru_select.bad'
        LOGFILE 'joshimiru_select.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            ページロケーション CHAR(400),
            ページタイトル CHAR(500),
            イベント数 FLOAT EXTERNAL
            )
        )
    LOCATION ('joshimiru_select_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from joshimiru_select_202605;
create table joshimiru_select_202605 as select * from joshimiru_select;
drop table joshimiru_select purge;

CREATE TABLE joshimiru_tap1(
    shop_id VARCHAR2(20),
    shop_name VARCHAR2(200),
    shop_area VARCHAR(75),
    shop_biz VARCHAR2(75),
    ランディング VARCHAR2(100),
    tap NUMBER(4)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'joshimiru_tap1.bad'
        LOGFILE 'joshimiru_tap1.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            shop_id CHAR(20),
            shop_name CHAR(200),
            shop_area CHAR(75),
            shop_biz CHAR(75),
            ランディング CHAR(100),
            tap FLOAT EXTERNAL
            )
        )
    LOCATION ('joshimiru_tap1_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from joshimiru_tap1_202605;
create table joshimiru_tap1_202605 as select * from joshimiru_tap1;
drop table joshimiru_tap1 purge;

CREATE TABLE joshimiru_tap2(
    shop_id VARCHAR2(20),
    shop_name VARCHAR2(200),
    shop_area VARCHAR(75),
    shop_biz VARCHAR2(75),
    ランディング VARCHAR2(100),
    tap NUMBER(4)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'joshimiru_tap2.bad'
        LOGFILE 'joshimiru_tap2.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            shop_id CHAR(20),
            shop_name CHAR(200),
            shop_area CHAR(75),
            shop_biz CHAR(75),
            ランディング CHAR(100),
            tap FLOAT EXTERNAL
            )
        )
    LOCATION ('joshimiru_tap2_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from joshimiru_tap2_202605;
create table joshimiru_tap2_202605 as select * from joshimiru_tap2;
drop table joshimiru_tap2 purge;

CREATE TABLE joshimiru_tap_202605(
  shop_id VARCHAR2(10),
  shop_name VARCHAR2(400),
  shop_area VARCHAR2(200),
  shop_biz VARCHAR2(100),
  ランディング VARCHAR2(400),
  tap NUMBER(5)
);

INSERT ALL
  INTO joshimiru_tap_202605
    VALUES(
      shop_id,
      shop_name,
      shop_area,
      shop_biz,
      ランディング,
      tap
    )
SELECT shop_id, shop_name, shop_area, shop_biz, ランディング, tap FROM joshimiru_tap2_202605
;


-- 演算
select * from sate_cca_tap_202605;
-- sate_cca_tap_YYYYMM（TAP合算用テーブルを作る時）
CREATE TABLE sate_cca_tap_202605(
  shop_id VARCHAR2(10),
  shop_name VARCHAR2(400),
  shop_area VARCHAR2(200),
  shop_biz VARCHAR2(100),
  ランディング VARCHAR2(400),
  tap NUMBER(5)
);

INSERT ALL
  INTO sate_cca_tap_202605
    VALUES(
      shop_id,
      shop_name,
      shop_area,
      shop_biz,
      ランディング,
      tap
    )
SELECT shop_id, shop_name, shop_area, shop_biz, ランディング, tap FROM joshimiru_tap_202605
;

-- サテライト別_TAP件数
SELECT
  (SELECT SUM(tap) FROM cocomiru_tap_202605) AS "ココミルTAP",
  (SELECT SUM(tap) FROM joshimiru_tap_202605) AS "ジョシミルTAP",
  (SELECT SUM(tap) FROM riramaga_tap_202605) AS "リラマガTAP",
  (SELECT SUM(tap) FROM cocomiru_tap_202605) +
  (SELECT SUM(tap) FROM riramaga_tap_202605) +
  (SELECT SUM(tap) FROM joshimiru_tap_202605) AS "合算TAP"  
FROM dual
;


-- 業種別用_TAP件数
SELECT
  (SELECT SUM(tap) FROM sate_cca_tap_202602 WHERE shop_biz = 'ヘルス') AS "ヘルス",
  (SELECT SUM(tap) FROM sate_cca_tap_202602 WHERE shop_biz = 'ソープ') AS "ソープ",
  (SELECT SUM(tap) FROM sate_cca_tap_202602 WHERE shop_biz = '風俗エステ') AS "風俗エステ",
  (SELECT SUM(tap) FROM sate_cca_tap_202602 WHERE shop_biz = 'メンズエステ') AS "メンズエステ",
  (SELECT SUM(tap) FROM sate_cca_tap_202602 WHERE shop_biz = 'ピンサロ') AS "ピンサロ",
  (SELECT SUM(tap) FROM sate_cca_tap_202602 WHERE shop_biz = 'デリヘル') AS "デリヘル",
  (SELECT SUM(tap) FROM sate_cca_tap_202602 WHERE shop_biz = 'チャットレディ') AS "チャットレディ",
  (SELECT SUM(tap) FROM sate_cca_tap_202602 WHERE shop_biz = 'ホテヘル') AS "ホテヘル",
  (SELECT SUM(tap) FROM sate_cca_tap_202602 WHERE shop_biz = 'AV女優') AS "AV女優"
FROM dual
;

-- 基本プラン別用_TAP件数
SELECT
  SUM(CASE WHEN a.契約プラン = 'Sプラン' THEN s.tap ELSE 0 END) AS "Sプラン",
  SUM(CASE WHEN a.契約プラン = 'Aプラン' THEN s.tap ELSE 0 END) AS "Aプラン",
  SUM(CASE WHEN a.契約プラン IN ('Bプラン', 'Cプラン', 'サービスC') THEN s.tap ELSE 0 END) AS "B/Cプラン",
  SUM(CASE WHEN a.契約プラン IN ('Eプラン（A）', 'Eプラン（B）', 'Eプラン（C）', 'Eプラン（D）', '無料') THEN s.tap ELSE 0 END) AS "E/無料プラン",
  SUM(CASE WHEN a.shop_id IS NULL THEN s.tap ELSE 0 END) AS "admin未登録"
FROM (
    SELECT shop_id, SUM(tap) AS tap
    FROM sate_cca_tap_202605
    GROUP BY shop_id
) s
LEFT JOIN admin_cca_202606 a
ON s.shop_id = a.shop_id
;
*/


-- sate_cca_session_YYYYMM（セッション合算用テーブルを作る時）

CREATE TABLE sate_cca_session_202605(
  ページロケーション VARCHAR2(400),
  ページタイトル VARCHAR2(500),
  イベント数 NUMBER(7)
);

INSERT ALL
  INTO sate_cca_session_202605
    VALUES(
      ページロケーション,
      ページタイトル,
      イベント数
    )
SELECT ページロケーション, ページタイトル, イベント数 FROM riramaga_session_202605
;

-- サテライト別_セッション数
SELECT
  (SELECT SUM(イベント数) FROM cocomiru_session_202605) "ココミルセッション",
  (SELECT SUM(イベント数) FROM joshimiru_session_202605) "ジョシミルセッション",
  (SELECT SUM(イベント数) FROM riramaga_session_202605) "リラマガセッション",
  (SELECT SUM(イベント数) FROM cocomiru_session_202605) +
  (SELECT SUM(イベント数) FROM riramaga_session_202605) +
  (SELECT SUM(イベント数) FROM joshimiru_session_202605) "合算セッション"  
FROM dual
;
*/


-- sate_cca_select_YYYYMM（送客合算用テーブルを作る時）

CREATE TABLE sate_cca_select_202605(
  ページロケーション VARCHAR2(400),
  イベント数 NUMBER(7)
);

INSERT ALL
  INTO sate_cca_select_202605
    VALUES(
      ページロケーション,
      イベント数
    )
SELECT ページロケーション, イベント数 FROM riramaga_select_202605
;

-- サテライト別_送客数
SELECT
  (SELECT SUM(イベント数) FROM cocomiru_select_202605) "ココミル-送客",
  (SELECT SUM(イベント数) FROM joshimiru_select_202605) "ジョシミル-送客",
  (SELECT SUM(イベント数) FROM riramaga_select_202605) "リラマガ-送客",
  (SELECT SUM(イベント数) FROM cocomiru_select_202605) +
  (SELECT SUM(イベント数) FROM riramaga_select_202605) +
  (SELECT SUM(イベント数) FROM joshimiru_select_202605) "合算送客"  
FROM dual
;
*/



-- サテライト合算_地方別_店舗一覧

SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン
FROM sate_cca_tap_202605 s INNER JOIN admin_cca_202606 a
ON s.shop_id = a.shop_id
  WHERE a.大エリア = '九州・沖縄'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC
;

/*支社レベル*/
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン
FROM sate_cca_tap_202605 s INNER JOIN admin_cca_202606 a
ON s.shop_id = a.shop_id
  WHERE a.都道府県 = '北海道'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC;

SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン
FROM sate_cca_tap_202605 s INNER JOIN admin_cca_202606 a
ON s.shop_id = a.shop_id
  WHERE a.都道府県 IN ('熊本県', '宮崎県', '鹿児島県', '沖縄県')
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC;


-- 西日本
SELECT
  a.大エリア,
  SUM(s.tap)
FROM sate_cca_tap_202605 s INNER JOIN admin_cca_202606 a
ON s.shop_id = a.shop_id
  WHERE a.大エリア IN ('関西', '中国・四国', '九州・沖縄')
GROUP BY a.大エリア
;

-- 東日本
SELECT
  a.大エリア,
  SUM(s.tap)
FROM sate_cca_tap_202605 s INNER JOIN admin_cca_202606 a
ON s.shop_id = a.shop_id
  WHERE a.大エリア IN ('北海道・東北', '関東', '中部')
GROUP BY a.大エリア
;



-- サテライト合算_業種別_店舗一覧
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン
FROM sate_cca_tap_202602 s INNER JOIN admin_cca_202602 a
ON s.shop_id = a.shop_id
  WHERE s.shop_biz = 'デリヘル'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC
;

-- 記事別用_店舗一覧
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  s.tap,
  s.ランディング,
  a.契約プラン
FROM sate_cca_tap_202604 s INNER JOIN admin_cca_202605 a
ON s.shop_id = a.shop_id
  -- WHERE 大エリア IN ('北海道・東北')
  -- WHERE 大エリア IN ('北海道・東北', '関東', '中部')
  WHERE s.shop_name LIKE 'CASA BIANCA（カーサ・ビアンカ%'
ORDER BY 4 DESC
;


select
  s.shop_name,
  sum(s.tap),
  s.shop_area,
  a.都道府県,
  a.店舗グループ,
  a.契約プラン
from sate_cca_tap_202604 s INNER JOIN admin_cca_202605 a
ON s.shop_id = a.shop_id
  WHERE 大エリア IN ('中国・四国')
  -- WHERE s.shop_name LIKE '美少女制服学園CLASSMATE%'
group by s.shop_name, s.shop_area, a.都道府県, a.店舗グループ, a.契約プラン
order by 2 desc
;
select 大エリア from admin_cca_202605 group by 大エリア;



-- admin_cca_YYYYMM を作る用

CREATE TABLE admin_cca(
    店舗id VARCHAR(50),
    店舗名 VARCHAR2(500),
    店舗url VARCHAR2(250),
    店舗グループ VARCHAR2(250),
    契約プラン VARCHAR2(50),
    大エリア VARCHAR2(50),
    都道府県 VARCHAR2(50),
    出発エリア VARCHAR2(100),
    業態 VARCHAR2(50),
    掲載開始日 DATE,
    掲載料金 VARCHAR2(20)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'admin_cca.bad'
        LOGFILE 'admin_cca.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            店舗id CHAR(50),
            店舗名 CHAR(500),
            店舗url CHAR(250),
            店舗グループ CHAR(250),
            契約プラン CHAR(50),
            大エリア CHAR(50),
            都道府県 CHAR(50),
            出発エリア CHAR(100),
            業態 CHAR(50),
            掲載開始日 CHAR DATE_FORMAT DATE MASK "YYYY-MM-DD",
            掲載料金 CHAR(20)
            )
        )
    LOCATION ('admin_cca_202606.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from admin_cca_202606;
create table admin_cca_202606 as select * from admin_cca;
drop table admin_cca purge;

-- admin_cca_YYYYMM に NUMBER型の掲載料金columnを作る用
ALTER TABLE admin_cca_202606
  ADD 掲載料金2 NUMBER(7)
;

UPDATE admin_cca_202606
  SET 掲載料金2 = REPLACE(掲載料金, ',')
;

ALTER TABLE admin_cca_202606
  DROP COLUMN 掲載料金
;

-- admin_cca_YYYYMM に shop_id 列を追加する用
ALTER TABLE admin_cca_202606
  ADD shop_id VARCHAR2(50)
;

UPDATE admin_cca_202606
  SET shop_id = REGEXP_SUBSTR(店舗url, 'shop/([0-9]+)', 1, 1, NULL, 1)
;






/*サマリーを作る用（エミリ系サテライト）*/
CREATE TABLE emiru_select(
    ページロケーション VARCHAR(400),
    ページタイトル VARCHAR2(500),
    イベント数 NUMBER(7)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'emiru_select.bad'
        LOGFILE 'emiru_select.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            ページロケーション CHAR(400),
            ページタイトル CHAR(500),
            イベント数 FLOAT EXTERNAL
            )
        )
    LOCATION ('emiru_select_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from emiru_select_202605;
create table emiru_select_202605 as select * from emiru_select;
drop table emiru_select purge;


CREATE TABLE emiru_tap(
    shop_id VARCHAR2(20),
    shop_name VARCHAR2(300),
    shop_area VARCHAR(75),
    shop_biz VARCHAR2(150),
    ランディング VARCHAR2(300),
    tap NUMBER(4)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'emiru_tap.bad'
        LOGFILE 'emiru_tap.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            shop_id CHAR(20),
            shop_name CHAR(300),
            shop_area CHAR(75),
            shop_biz CHAR(150),
            ランディング CHAR(300),
            tap FLOAT EXTERNAL
            )
        )
    LOCATION ('emiru_tap_202605.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from emiru_tap_202605;
create table emiru_tap_202605 as select * from emiru_tap;
drop table emiru_tap purge;



-- サテライト合算_地方別_店舗一覧

SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン
FROM sate_cca_tap_202605 s INNER JOIN admin_cca_202606 a
ON s.shop_id = a.shop_id
  WHERE a.大エリア = '九州・沖縄'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC
;

/*支社レベル*/
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン
FROM sate_cca_tap_202605 s INNER JOIN admin_cca_202606 a
ON s.shop_id = a.shop_id
  WHERE a.都道府県 = '北海道'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC;

SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン
FROM sate_cca_tap_202605 s INNER JOIN admin_cca_202606 a
ON s.shop_id = a.shop_id
  WHERE a.都道府県 IN ('熊本県', '宮崎県', '鹿児島県', '沖縄県')
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC;


-- 西日本
SELECT
  a.大エリア,
  SUM(s.tap)
FROM sate_cca_tap_202605 s INNER JOIN admin_cca_202606 a
ON s.shop_id = a.shop_id
  WHERE a.大エリア IN ('関西', '中国・四国', '九州・沖縄')
GROUP BY a.大エリア
;

-- 東日本
SELECT
  a.大エリア,
  SUM(s.tap)
FROM sate_cca_tap_202605 s INNER JOIN admin_cca_202606 a
ON s.shop_id = a.shop_id
  WHERE a.大エリア IN ('北海道・東北', '関東', '中部')
GROUP BY a.大エリア
;



-- サテライト合算_業種別_店舗一覧
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  SUM(s.tap),
  a.契約プラン
FROM sate_cca_tap_202602 s INNER JOIN admin_cca_202602 a
ON s.shop_id = a.shop_id
  WHERE s.shop_biz = 'デリヘル'
GROUP BY s.shop_name, s.shop_area, s.shop_biz, a.契約プラン
ORDER BY 4 DESC
;

-- 記事別用_店舗一覧
SELECT
  s.shop_name,
  s.shop_area,
  s.shop_biz,
  s.tap,
  s.ランディング,
  a.契約プラン
FROM sate_cca_tap_202604 s INNER JOIN admin_cca_202605 a
ON s.shop_id = a.shop_id
  -- WHERE 大エリア IN ('北海道・東北')
  -- WHERE 大エリア IN ('北海道・東北', '関東', '中部')
  WHERE s.shop_name LIKE 'CASA BIANCA（カーサ・ビアンカ%'
ORDER BY 4 DESC
;


select
  s.shop_name,
  sum(s.tap),
  s.shop_area,
  a.都道府県,
  a.店舗グループ,
  a.契約プラン
from sate_cca_tap_202604 s INNER JOIN admin_cca_202605 a
ON s.shop_id = a.shop_id
  WHERE 大エリア IN ('中国・四国')
  -- WHERE s.shop_name LIKE '美少女制服学園CLASSMATE%'
group by s.shop_name, s.shop_area, a.都道府県, a.店舗グループ, a.契約プラン
order by 2 desc
;
select 大エリア from admin_cca_202605 group by 大エリア;



-- admin_emi_YYYYMM を作る用

CREATE TABLE admin_emi(
    店舗id VARCHAR(50),
    店舗名 VARCHAR2(500),
    店舗url VARCHAR2(250),
    契約プラン VARCHAR2(50),
    大エリア VARCHAR2(50),
    都道府県 VARCHAR2(50),
    出発エリア VARCHAR2(100),
    業態 VARCHAR2(50)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'admin_emi.bad'
        LOGFILE 'admin_emi.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            店舗id CHAR(50),
            店舗名 CHAR(500),
            店舗url CHAR(250),
            契約プラン CHAR(50),
            大エリア CHAR(50),
            都道府県 CHAR(50),
            出発エリア CHAR(100),
            業態 CHAR(50)
            )
        )
    LOCATION ('admin_emi_202606.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from admin_emi_202606;
create table admin_emi_202606 as select * from admin_emi;
drop table admin_emi purge;


-- admin_emi_YYYYMM に shop_id 列を追加する用
ALTER TABLE admin_emi_202606
  ADD shop_id VARCHAR2(50)
;

UPDATE admin_emi_202606
  SET shop_id = REGEXP_SUBSTR(店舗URL, '/([0-9]+)/?$', 1, 1, NULL, 1)
;









-- admin_2ka_YYYYMM を作る用
CREATE TABLE admin_2ka(
    キーID NUMBER(4),
    カテゴリー名 VARCHAR2(50),
    件名 VARCHAR2(300),
    担当者 VARCHAR2(100),
    実働時間 NUMBER(5,2),
    更新日 DATE,
    媒体 VARCHAR2(50),
    種別 VARCHAR2(50),
    作業内容 VARCHAR2(50),
    本数 NUMBER(4,1)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'admin_2ka.bad'
        LOGFILE 'admin_2ka.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            キーID FLOAT EXTERNAL,
            カテゴリー名 CHAR(50),
            件名 CHAR(300),
            担当者 CHAR(100),
            実働時間 FLOAT EXTERNAL,
            更新日 CHAR DATE_FORMAT DATE MASK "YYYY-MM-DD",
            媒体 CHAR(50),
            種別 CHAR(50),
            作業内容 CHAR(50),
            本数 FLOAT EXTERNAL
            )
        )
    LOCATION ('admin_2ka.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from admin_2ka;
create table admin_2ka_202605 as select * from admin_2ka;
select * from admin_2ka_202605;
drop table admin_2ka purge;


select 担当者, 作業内容, SUM(本数), SUM(実働時間) from admin_2ka_202605
where 担当者 LIKE '%石田%'
group by 担当者, 作業内容;

select 件名, 担当者, 実働時間, 種別, 作業内容, 本数 from admin_2ka_202605
where 作業内容 = '分析'
and 担当者 LIKE '%石田%';








-- 口コミの件
/*インデックス登録済reviewページ*/
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








/*統合とスコア算出まで*/
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








-- リラマガ（CV, セッション, サチコ）
/*CV*/
CREATE TABLE riramaga_cv(
    ランディングページ VARCHAR2(500),
    apply_starting_point NUMBER(4),
    sns_starting_point NUMBER(4),
    tel_starting_point NUMBER(4),
    合計 NUMBER(4)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'riramaga_cv.bad'
        LOGFILE 'riramaga_cv.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            ランディングページ CHAR(500),
            apply_starting_point FLOAT EXTERNAL,
            sns_starting_point FLOAT EXTERNAL,
            tel_starting_point FLOAT EXTERNAL,
            合計 FLOAT EXTERNAL
            )
        )
    LOCATION ('riramaga_cv.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from riramaga_cv;
create table riramaga_cv_202605 as select * from riramaga_cv;
select * from riramaga_cv_202605;
drop table riramaga_cv purge;

/*session*/
CREATE TABLE riramaga_session(
    ランディングページ VARCHAR2(500),
    ページタイトル VARCHAR2(500),
    セッション数 NUMBER(6)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'riramaga_session.bad'
        LOGFILE 'riramaga_session.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            ランディングページ CHAR(500),
            ページタイトル CHAR(500),
            セッション数 FLOAT EXTERNAL
            )
        )
    LOCATION ('riramaga_session.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from riramaga_session;
create table riramaga_session_202606 as select * from riramaga_session;
select * from riramaga_session_202606;
drop table riramaga_session purge;



/*サチコ（SC）*/
CREATE TABLE riramaga_sc(
    上位のページ VARCHAR2(500),
    クリック数 NUMBER(6),
    表示回数 NUMBER(7),
    CTR VARCHAR2(30),
    掲載順位 NUMBER(4, 2)
    )
    ORGANIZATION EXTERNAL
    (TYPE ORACLE_LOADER
    DEFAULT DIRECTORY temp_dir
    ACCESS PARAMETERS
        (RECORDS DELIMITED BY NEWLINE
        SKIP 1
        BADFILE 'riramaga_sc.bad'
        LOGFILE 'riramaga_sc.log'
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
            (
            上位のページ CHAR(500),
            クリック数 FLOAT EXTERNAL,
            表示回数 FLOAT EXTERNAL,
            CTR CHAR(30),
            掲載順位 FLOAT EXTERNAL
            )
        )
    LOCATION ('riramaga_sc.csv')
    )
    REJECT LIMIT UNLIMITED
;

select * from riramaga_sc;
create table riramaga_sc_202606 as select * from riramaga_sc;
select * from riramaga_sc_202606;
drop table riramaga_sc purge;


/*3テーブルを全部まとめるSQL*/
WITH
cv AS (
    SELECT
        ランディングページ,
        SUM(APPLY_STARTING_POINT) AS APPLY_STARTING_POINT,
        SUM(SNS_STARTING_POINT) AS SNS_STARTING_POINT,
        SUM(TEL_STARTING_POINT) AS TEL_STARTING_POINT,
        SUM(合計) AS CV合計
    FROM riramaga_cv_202605
    GROUP BY ランディングページ
),
ss AS (
    SELECT
        ランディングページ,
        MIN(ページタイトル) AS ページタイトル,
        SUM(セッション数) AS セッション数
    FROM riramaga_session_202605
    GROUP BY ランディングページ
),
sc AS (
    SELECT
        上位のページ AS ランディングページ,
        SUM(クリック数) AS クリック数,
        SUM(表示回数) AS 表示回数,
        ROUND(
            CASE
                WHEN SUM(表示回数) = 0 THEN 0
                ELSE SUM(クリック数) / SUM(表示回数) * 100
            END,
            2
        ) AS CTR,
        ROUND(AVG(掲載順位), 2) AS 掲載順位
    FROM riramaga_sc_202605
    GROUP BY 上位のページ
)
SELECT
    CONCAT('https://menesth-job.jp', COALESCE(cv.ランディングページ, ss.ランディングページ, sc.ランディングページ)) AS ランディングページ,
    ss.ページタイトル,
    NVL(ss.セッション数, 0) AS セッション数,
    NVL(sc.クリック数, 0) AS クリック数,
    NVL(sc.表示回数, 0) AS 表示回数,
    NVL(sc.CTR, 0) AS CTR,
    sc.掲載順位,
    NVL(cv.APPLY_STARTING_POINT, 0) AS APPLY_STARTING_POINT,
    NVL(cv.SNS_STARTING_POINT, 0) AS SNS_STARTING_POINT,
    NVL(cv.TEL_STARTING_POINT, 0) AS TEL_STARTING_POINT,
    NVL(cv.CV合計, 0) AS CV合計
FROM cv
FULL OUTER JOIN ss
    ON cv.ランディングページ = ss.ランディングページ
FULL OUTER JOIN sc
    ON COALESCE(cv.ランディングページ, ss.ランディングページ) = sc.ランディングページ
ORDER BY
    セッション数 DESC,
    CV合計 DESC,
    クリック数 DESC;


















