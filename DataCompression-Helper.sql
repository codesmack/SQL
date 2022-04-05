-- Reference Article: https://www.sqlshack.com/use-sql-server-data-compression-save-space/
-- Query #1: Check compression opportunity
 SELECT DISTINCT
    s.name,
    t.name,
    i.name,
    i.type,
    i.index_id,
    p.partition_number,
    p.rows
FROM sys.tables t
LEFT JOIN sys.indexes i
ON t.object_id = i.object_id
JOIN sys.schemas s
ON t.schema_id = s.schema_id
LEFT JOIN sys.partitions p
ON i.index_id = p.index_id
    AND t.object_id = p.object_id
WHERE t.type = 'U' 
  AND p.data_compression_desc = 'NONE'
ORDER BY p.rows desc
 
-- Query #2: Check compression worth (use data from query #1)
exec sp_estimate_data_compression_savings @schema_name = 'dbo', @object_name = '<Table_Name>', @index_id = NULL, @partition_number = NULL, @data_compression = 'PAGE'
exec sp_estimate_data_compression_savings @schema_name = 'dbo', @object_name = '<Table_Name>', @index_id = NULL, @partition_number = NULL, @data_compression = 'ROW'

-- Query #3: Compression Query (use data from query #1 and make decision using query #2)
ALTER INDEX <Index_Name> ON <Table_Name> REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);  --Page Level
ALTER INDEX <Index_Name> ON <Table_Name> REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = ROW); --Row Level
