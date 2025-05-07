-- 1. 创建测试表
CREATE TABLE articles (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. 插入测试数据
INSERT INTO articles (title, content) VALUES
('保障房政策解读', '2022 年保障房建设政策出台，各地政府加大保障房资金投入，缓解住房压力。新政策要求加强资金监管，确保专款专用。'),
('房地产市场分析', '近年来房价持续上涨，保障房成为解决中低收入群体住房问题的重要手段。保障房建设面临资金压力，需要创新融资模式。'),
('保障房建设现状', '全国保障房建设规模不断扩大，但资金缺口仍然很大。地方政府债务压力加大，保障房资金来源渠道有限。'),
('住房问题研究', '住房问题是民生工程，商品房价格过高导致购房困难。保障房是解决方案之一，但建设速度慢，资金问题是主要瓶颈。'),
('城市规划与住房', '城市化进程加快，住房需求增加。保障房在城市规划中占比提升，但土地和资金问题制约发展速度。'),
('资金压力与政策', '保障房资金压力主要来自建设成本高和回报周期长。政府补贴和税收优惠是缓解资金压力的主要手段。');

-- 3. 确保 zhparser 扩展已启用（假设已按测试文件中的方式配置好了）
-- 如果尚未配置，请先执行：
-- CREATE EXTENSION zhparser;
-- CREATE TEXT SEARCH CONFIGURATION zhcfg (PARSER = zhparser);
-- ALTER TEXT SEARCH CONFIGURATION zhcfg ADD MAPPING FOR n,v,a,i,e,l WITH simple;

-- 4. 创建全文检索索引
CREATE INDEX idx_fts_content ON articles USING GIN (to_tsvector('zhcfg', content));
CREATE INDEX idx_fts_title ON articles USING GIN (to_tsvector('zhcfg', title));

-- 5. 基本全文检索查询（按相关性排序）
SELECT 
    id, 
    title, 
    content,
    ts_rank(to_tsvector('zhcfg', content), to_tsquery('zhcfg', '保障房 & 资金 & 压力')) AS rank
FROM 
    articles
WHERE 
    to_tsvector('zhcfg', content) @@ to_tsquery('zhcfg', '保障房 & 资金 & 压力')
ORDER BY 
    rank DESC;

-- 6. 标题和内容综合检索（加权排序）
SELECT 
    id, 
    title, 
    content,
    ts_rank(setweight(to_tsvector('zhcfg', title), 'A') || 
            setweight(to_tsvector('zhcfg', content), 'B'),
            to_tsquery('zhcfg', '保障房 & 资金 & 压力')) AS rank
FROM 
    articles
WHERE 
    to_tsvector('zhcfg', title) @@ to_tsquery('zhcfg', '保障房 | 资金 | 压力') OR
    to_tsvector('zhcfg', content) @@ to_tsquery('zhcfg', '保障房 & 资金 & 压力')
ORDER BY 
    rank DESC;

-- 7. 使用 ts_rank_cd 进行相关性排序（考虑词语位置）
SELECT 
    id, 
    title, 
    substring(content, 1, 50) || '...' AS content_preview,
    ts_rank_cd(to_tsvector('zhcfg', content), to_tsquery('zhcfg', '保障房 & 资金 & 压力')) AS rank
FROM 
    articles
WHERE 
    to_tsvector('zhcfg', content) @@ to_tsquery('zhcfg', '保障房 & 资金 & 压力')
ORDER BY 
    rank DESC;

-- 8. 结合其他排序条件
SELECT 
    id, 
    title, 
    substring(content, 1, 50) || '...' AS content_preview,
    ts_rank(to_tsvector('zhcfg', content), to_tsquery('zhcfg', '保障房 & 资金')) AS rank,
    created_at
FROM 
    articles
WHERE 
    to_tsvector('zhcfg', content) @@ to_tsquery('zhcfg', '保障房 & 资金')
ORDER BY 
    rank DESC, 
    created_at DESC;

-- 9. 高亮显示匹配的文本
SELECT 
    id, 
    title,
    ts_headline('zhcfg', content, to_tsquery('zhcfg', '保障房 & 资金 & 压力'), 
                'StartSel=<b>, StopSel=</b>, MaxWords=50, MinWords=10') AS highlighted_content,
    ts_rank(to_tsvector('zhcfg', content), to_tsquery('zhcfg', '保障房 & 资金 & 压力')) AS rank
FROM 
    articles
WHERE 
    to_tsvector('zhcfg', content) @@ to_tsquery('zhcfg', '保障房 & 资金 & 压力')
ORDER BY 
    rank DESC;