-- 检查拓展
SELECT * FROM pg_available_extensions where name='zhparser' or name='vectors';

-- 检查扩展是否已启用
SELECT
    e.extname AS "扩展名称",
    CASE
        WHEN e.extname IS NOT NULL THEN '已启用'
        ELSE '未启用'
    END AS "状态"
FROM pg_extension e
WHERE e.extname IN ('zhparser', 'vectors')
UNION ALL
SELECT
    name AS "扩展名称",
    '未启用' AS "状态"
FROM pg_available_extensions
WHERE name IN ('zhparser', 'vectors')
AND name NOT IN (SELECT extname FROM pg_extension);


-- 开启向量拓展
DROP EXTENSION IF EXISTS vectors;
CREATE EXTENSION vectors;

-- 开启中文分词器
DROP EXTENSION IF EXISTS zhparser;
CREATE EXTENSION zhparser;
-- make test configuration using parser
CREATE TEXT SEARCH CONFIGURATION zhcfg (PARSER = zhparser);
-- add token mapping
ALTER TEXT SEARCH CONFIGURATION zhcfg ADD MAPPING FOR n,v,a,i,e,l WITH simple;

-- 测试中文分词器
SELECT * FROM ts_parse('zhparser', 'hello world! 2010年保障房建设在全国范围内获全面启动');
-- ts_parse
SELECT * FROM ts_parse('zhparser', 'hello world! 2010年保障房建设在全国范围内获全面启动，从中央到地方纷纷加大 了保障房的建设和投入力度 。2011年，保障房进入了更大规模的建设阶段。住房城乡建设部党组书记、部长姜伟新去年底在全国住房城乡建设工作会议上表示，要继续推进保障性安居工程建设。');
-- test to_tsvector
SELECT to_tsvector('zhcfg','“今年保障房新开工数量虽然有所下调，但实际的年度在建规模以及竣工规模会超以往年份，相对应的对资金的需求也会创历>史纪录。”陈国强说。在他看来，与2011年相比，2012年的保障房建设在资金配套上的压力将更为严峻。');
-- test to_tsquery
SELECT to_tsquery('zhcfg', '保障房资金压力');

-- create table with a vector column
CREATE TABLE items (
  id bigserial PRIMARY KEY,
  embedding vector(3) NOT NULL -- 3 dimensions
);

SELECT * FROM ts_parse('zhparser', '清华大学和西交利物浦大学以及家里蹲大学等，欢迎入学');

-- insert values
INSERT INTO items (embedding)
VALUES ('[1,2,3]'), ('[4,5,6]');

-- or insert values using a casting from array to vector
INSERT INTO items (embedding)
VALUES (ARRAY[1, 2, 3]::real[]), (ARRAY[4, 5, 6]::real[]);

-- query the similar embeddings
SELECT * FROM items ORDER BY embedding <-> '[3,2,1]' LIMIT 5;