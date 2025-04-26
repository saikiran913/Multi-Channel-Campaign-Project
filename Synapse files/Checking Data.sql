SELECT * FROM DimCampaign

select * from dimchannel

select * from factcampaignperformance

SELECT * from stg_CampaignData

SELECT COUNT(*)
FROM factcampaignperformance;

SELECT TOP 100 campaign_id, campaign_name, standardized_campaign_name
FROM DimCampaign;

SELECT TOP 100 *
FROM FactCampaignPerformance
ORDER BY date DESC;

SELECT *
FROM FactCampaignPerformance
WHERE CTR IS NULL OR CPC IS NULL;



UPDATE DimCampaign
SET standardized_campaign_name = UPPER(LTRIM(RTRIM(campaign_name)))
WHERE standardized_campaign_name IS NULL;


EXEC dbo.upsert_Dimchannel

EXEC dbo.upsert_dimcampaign

exec dbo.insert_factcampaignperformance

DECLARE @current_datetime DATETIME = GETDATE();




IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.insert_FactCampaignPerformance') AND type IN (N'P'))
DROP PROCEDURE dbo.insert_FactCampaignPerformance;
GO

CREATE PROCEDURE dbo.insert_FactCampaignPerformance
AS
BEGIN
    -- Insert performance data into Fact table with NULLs handled correctly
    INSERT INTO FactCampaignPerformance (campaign_key, date, impressions, clicks, spend, CTR, CPC)
    SELECT
        dc.campaign_key,
        s.date,
        ISNULL(s.impressions, 0) AS impressions,
        ISNULL(s.clicks, 0) AS clicks,
        ISNULL(s.spend, 0) AS spend,
        CASE 
            WHEN ISNULL(s.impressions, 0) > 0 THEN (ISNULL(s.clicks, 0) * 100.0 / ISNULL(s.impressions, 0))
            ELSE 0 
        END AS CTR,
        CASE 
            WHEN ISNULL(s.clicks, 0) > 0 THEN (ISNULL(s.spend, 0) / ISNULL(s.clicks, 0))
            ELSE 0 
        END AS CPC
    FROM stg_CampaignData s
    JOIN DimCampaign dc ON s.campaign_id = dc.campaign_id
    WHERE dc.active_flag = 'Y';
END;


SELECT * from stg_CampaignData order by date desc;

SELECT TOP 30 * FROM stg_CampaignData ORDER BY date DESC;




-- Check how many campaigns exist
SELECT COUNT(*) FROM DimCampaign;

-- Check new or updated campaigns
SELECT * 
FROM DimCampaign
ORDER BY effective_date DESC;


-- Check expired campaigns
SELECT * 
FROM DimCampaign
WHERE active_flag = 'N';


-- Check total fact records
SELECT COUNT(*) FROM dimcampaign;

-- Check new performance rows
SELECT * 
FROM FactCampaignPerformance
ORDER BY date DESC;


SELECT date, COUNT(*) AS records_per_day
FROM FactCampaignPerformance
GROUP BY date
ORDER BY date DESC;


-- Validate Standardized Campaign Names
SELECT campaign_id, campaign_name, standardized_campaign_name
FROM DimCampaign
ORDER BY effective_date DESC;

-- Validate CTR and CPC values
SELECT campaign_key, date, impressions, clicks, spend, CTR, CPC
FROM FactCampaignPerformance
ORDER BY date DESC;

