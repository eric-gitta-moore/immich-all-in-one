-- 开启向量拓展
CREATE EXTENSION IF NOT EXISTS vectors;

-- 开启中文分词器
CREATE EXTENSION IF NOT EXISTS zhparser;
-- make test configuration using parser
CREATE TEXT SEARCH CONFIGURATION chinese (PARSER = zhparser);
-- add token mapping
ALTER TEXT SEARCH CONFIGURATION chinese ADD MAPPING FOR n,v,a,i,e,l WITH simple;