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