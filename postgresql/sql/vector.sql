-- PGVECTOR 和全文检索混合排序演示

-- 1. 确保扩展已安装
CREATE EXTENSION IF NOT EXISTS vectors;
CREATE EXTENSION IF NOT EXISTS zhparser;

-- 2. 创建中文分词配置（如果尚未配置）
CREATE TEXT SEARCH CONFIGURATION IF NOT EXISTS zhcfg (PARSER = zhparser);
ALTER TEXT SEARCH CONFIGURATION zhcfg ADD MAPPING FOR n,v,a,i,e,l WITH simple;

-- 3. 创建文章表（包含向量和文本）
DROP TABLE IF EXISTS article_hybrid;
CREATE TABLE article_hybrid (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    -- 使用 768 维向量（模拟 BERT 或类似模型的嵌入向量）
    content_embedding vector(768) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. 创建索引
CREATE INDEX idx_fts_hybrid_title ON article_hybrid USING GIN (to_tsvector('zhcfg', title));
CREATE INDEX idx_fts_hybrid_content ON article_hybrid USING GIN (to_tsvector('zhcfg', content));
CREATE INDEX idx_vector_hybrid ON article_hybrid USING ivfflat (content_embedding vector_l2_ops);

-- 5. 插入测试数据（使用随机生成的向量）
-- 模拟函数：生成随机向量
CREATE OR REPLACE FUNCTION random_embedding(dim INTEGER) 
RETURNS vector AS $$
DECLARE
    result float8[];
BEGIN
    FOR i IN 1..dim LOOP
        result[i] := (random() - 0.5) * 2;  -- 生成 -1 到 1 之间的随机值
    END LOOP;
    RETURN result::vector;
END;
$$ LANGUAGE plpgsql;

-- 插入测试数据
INSERT INTO article_hybrid (title, content, content_embedding) VALUES
-- 房地产相关文章
('中国保障房政策解析', '近年来中国政府加大保障房建设力度，解决低收入人群住房问题。保障房资金主要来源于政府补贴和专项基金，但资金压力依然较大。各地方政府陆续推出各种举措缓解保障房资金压力，包括 PPP 模式和税收优惠政策。', random_embedding(768)),
('房地产市场降温与保障房建设', '2023 年全国房地产市场整体呈现降温趋势，商品房销售面积下降。与此同时，保障房建设却在加速推进，资金投入持续增加。分析师认为保障房将成为稳定房地产市场的重要力量。', random_embedding(768)),
('保障房建设中的资金困境', '保障房建设面临严峻的资金压力，建设成本不断攀升，而回报周期长。地方政府债务负担加重，难以持续大规模投入。专家建议引入社会资本，多渠道解决保障房资金问题。', random_embedding(768)),
('公租房 vs 经济适用房：模式对比', '公租房和经济适用房是两种主要的保障房类型，在建设资金来源和运营模式上存在显著差异。公租房更依赖持续的政府补贴，而经济适用房则强调一次性投入和市场化运作。', random_embedding(768)),
('保障房社区规划与社会融合', '保障房社区规划应注重与商品房社区的融合，避免贫困集中和空间隔离。合理的社区规划可以降低后期管理成本和社会问题，缓解财政压力。', random_embedding(768)),

-- 金融相关文章
('房地产金融风险分析', '房地产行业金融风险日益凸显，银行压缩房地产贷款规模。保障房建设的金融支持模式需要创新，资金压力传导至整个产业链。政府考虑设立专项债券支持保障房建设。', random_embedding(768)),
('保障房建设融资新模式', '传统依靠财政拨款的保障房建设模式难以为继，多元化融资成为趋势。REITs、市政债券、社会资本合作等新型融资方式为保障房建设提供资金支持。', random_embedding(768)),
('地方政府债务与保障房建设', '地方政府债务规模扩大，影响保障房建设资金投入能力。部分城市保障房项目因资金问题停滞，亟需解决资金压力问题。中央政府出台多项政策支持地方保障房建设。', random_embedding(768)),
('保障房资产证券化探索', '保障房资产证券化是缓解资金压力的创新方式，可盘活存量资产。多地开展保障房 REITs 试点，市场反应积极，有望扩大试点范围。资金回笼后将继续投入新建保障房项目。', random_embedding(768)),
('经济下行对保障房政策影响', '经济增速放缓背景下，政府调整保障房建设节奏，优化资金配置。保障房投资被视为稳增长的重要手段，但资金压力限制了规模扩张。', random_embedding(768)),

-- 社会问题相关文章
('保障房分配公平性问题研究', '保障房分配中存在诸多公平性问题，影响政策效果。完善准入和退出机制是保障资源高效利用的关键。公开透明的分配流程可以提高民众满意度和资金使用效率。', random_embedding(768)),
('城市化进程中的住房保障', '快速城市化带来大量新市民住房需求，保障房供应严重不足。资金限制是扩大保障房覆盖面的主要障碍。创新土地供应和资金筹措机制是解决问题的关键。', random_embedding(768)),
('保障房政策国际比较', '对比中国、新加坡、德国等国家的保障房政策，发现资金来源多元化是国际通行做法。税收优惠和金融支持是减轻政府直接资金压力的有效手段。', random_embedding(768)),
('住房保障与社会福利体系', '住房保障是社会福利体系的重要组成部分，与医疗、教育等领域存在资源竞争关系。合理配置财政资源，平衡各项民生支出是政府面临的难题。', random_embedding(768)),
('保障房与房地产市场调控', '保障房建设是房地产市场长效调控机制的组成部分，对稳定房价有积极作用。增加保障房供应需要大量资金投入，市场化机制可以部分缓解资金压力。', random_embedding(768)),

-- 建筑技术相关文章
('保障房建设成本控制技术', '保障房建设面临控制成本与保证质量的双重挑战。新型建筑技术和材料可以降低建设成本，缓解资金压力。装配式建筑在保障房项目中的应用日益广泛。', random_embedding(768)),
('绿色保障房建设实践', '绿色建筑理念在保障房项目中的应用，虽然前期投入较大，但长期运营成本显著降低。能源效率提升可以减轻居民负担，间接缓解政府补贴压力。', random_embedding(768)),
('保障房小区规划与设计', '保障房小区规划应兼顾经济性和宜居性，合理控制建设标准和成本。精细化设计可以在有限资金约束下提升居住品质，实现社会效益最大化。', random_embedding(768)),
('保障房质量监管与责任', '保障房建设中的质量问题时有发生，加强监管势在必行。在资金有限的情况下，如何保证工程质量是一个系统性挑战。建立全过程质量责任制是有效解决方案。', random_embedding(768)),
('保障房维护与管理成本', '保障房项目后期维护和管理成本不容忽视，直接影响可持续运营。建立合理的租金定价和物业费机制，可以减轻长期财政负担和资金压力。', random_embedding(768)),

-- 政策研究相关文章
('十四五期间保障房发展规划', '十四五规划明确提出加大保障房建设力度，拓宽资金来源渠道。中央财政将增加转移支付，支持地方保障房建设。金融机构提供优惠贷款也是缓解资金压力的重要措施。', random_embedding(768)),
('住房保障立法研究', '完善住房保障法律体系，为多元化资金筹措提供法律保障。明确各级政府责任，规范社会资本参与机制，有助于缓解保障房资金压力。', random_embedding(768)),
('人口结构变化与保障房需求', '人口老龄化背景下，养老型保障房需求增加，对财政提出新挑战。年轻人住房困难问题也需要政策关注，平衡各类需求下的资金分配至关重要。', random_embedding(768)),
('保障房政策执行评估', '各地保障房政策执行情况参差不齐，资金使用效率有待提高。建立科学的评估机制，优化资源配置，是提升政策效果的关键。', random_embedding(768)),
('住房公积金与保障房联动', '盘活住房公积金资源，支持保障房建设是缓解资金压力的有效途径。适度提高公积金贷款额度用于保障房建设，可以形成良性循环。', random_embedding(768));

-- 6. 创建一个查询向量（模拟用户查询的嵌入）
-- 在实际应用中，这个向量应该是通过模型实时生成的
CREATE OR REPLACE FUNCTION query_embedding() 
RETURNS vector AS $$
BEGIN
    -- 随机生成一个查询向量（实际应用中应该是基于用户查询文本通过模型生成）
    RETURN random_embedding(768);
END;
$$ LANGUAGE plpgsql;

-- 7. 混合查询函数
CREATE OR REPLACE FUNCTION hybrid_search(
    search_query TEXT,
    vector_weight FLOAT DEFAULT 0.5,
    text_weight FLOAT DEFAULT 0.5,
    limit_val INTEGER DEFAULT 10
) 
RETURNS TABLE (
    id INTEGER,
    title TEXT,
    content TEXT,
    vector_score FLOAT,
    text_score FLOAT,
    combined_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    WITH vector_results AS (
        SELECT 
            id, 
            1 - (content_embedding <-> query_embedding()) AS similarity_score
        FROM 
            article_hybrid
        ORDER BY 
            content_embedding <-> query_embedding()
        LIMIT 50  -- 获取更多向量结果，然后与文本结果合并
    ),
    text_results AS (
        SELECT 
            id,
            ts_rank(
                setweight(to_tsvector('zhcfg', title), 'A') || 
                setweight(to_tsvector('zhcfg', content), 'B'),
                to_tsquery('zhcfg', search_query)
            ) AS text_score
        FROM 
            article_hybrid
        WHERE 
            to_tsvector('zhcfg', title) @@ to_tsquery('zhcfg', search_query) OR
            to_tsvector('zhcfg', content) @@ to_tsquery('zhcfg', search_query)
        LIMIT 50  -- 获取更多文本结果，然后与向量结果合并
    ),
    combined_results AS (
        SELECT 
            a.id,
            a.title,
            a.content,
            COALESCE(v.similarity_score, 0) AS vector_score,
            COALESCE(t.text_score, 0) AS text_score,
            (COALESCE(v.similarity_score, 0) * vector_weight + 
             COALESCE(t.text_score, 0) * text_weight) AS combined_score
        FROM 
            article_hybrid a
        LEFT JOIN 
            vector_results v ON a.id = v.id
        LEFT JOIN 
            text_results t ON a.id = t.id
        WHERE 
            v.id IS NOT NULL OR t.id IS NOT NULL
    )
    SELECT * FROM combined_results
    ORDER BY combined_score DESC
    LIMIT limit_val;
END;
$$ LANGUAGE plpgsql;

-- 8. 演示查询
-- 8.1 仅向量查询
SELECT 
    id, 
    title, 
    substring(content, 1, 50) || '...' AS content_snippet,
    1 - (content_embedding <-> query_embedding()) AS similarity
FROM 
    article_hybrid
ORDER BY 
    content_embedding <-> query_embedding()
LIMIT 5;

-- 8.2 仅全文检索查询
SELECT 
    id, 
    title, 
    substring(content, 1, 50) || '...' AS content_snippet,
    ts_rank(to_tsvector('zhcfg', content), to_tsquery('zhcfg', '保障房 & 资金 & 压力')) AS rank
FROM 
    article_hybrid
WHERE 
    to_tsvector('zhcfg', content) @@ to_tsquery('zhcfg', '保障房 & 资金 & 压力')
ORDER BY 
    rank DESC
LIMIT 5;

-- 8.3 混合查询（不同权重组合）
-- 向量和文本权重相等 (0.5:0.5)
SELECT * FROM hybrid_search('保障房 & 资金 & 压力', 0.5, 0.5, 10);

-- 向量权重更高 (0.8:0.2)
SELECT * FROM hybrid_search('保障房 & 资金 & 压力', 0.8, 0.2, 10);

-- 文本权重更高 (0.2:0.8)
SELECT * FROM hybrid_search('保障房 & 资金 & 压力', 0.2, 0.8, 10);

-- 8.4 高亮显示结果
WITH hybrid_results AS (
    SELECT id, title, content, combined_score
    FROM hybrid_search('保障房 & 资金 & 压力', 0.5, 0.5, 5)
)
SELECT 
    h.id,
    h.title,
    ts_headline('zhcfg', h.content, to_tsquery('zhcfg', '保障房 & 资金 & 压力'),
               'StartSel=<b>, StopSel=</b>, MaxWords=35, MinWords=15') AS highlighted_content,
    h.combined_score
FROM 
    hybrid_results h
ORDER BY 
    h.combined_score DESC;

-- 9. 清理函数（可选）
-- DROP FUNCTION IF EXISTS random_embedding(INTEGER);
-- DROP FUNCTION IF EXISTS query_embedding();
-- DROP FUNCTION IF EXISTS hybrid_search(TEXT, FLOAT, FLOAT, INTEGER);
