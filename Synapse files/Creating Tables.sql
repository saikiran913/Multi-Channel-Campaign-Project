CREATE TABLE stg_CampaignData (
  campaign_id NVARCHAR(50),
  campaign_name NVARCHAR(255),
  channel NVARCHAR(50),
  impressions INT,
  clicks INT,
  spend FLOAT,
  date DATE
);

CREATE TABLE DimChannel (
    channel_key INT IDENTITY(1,1),
    channel_name NVARCHAR(100),
    active_flag CHAR(1),
    effective_date DATETIME,
    expiry_date DATETIME,
    CONSTRAINT PK_DimChannel PRIMARY KEY NONCLUSTERED (channel_key) NOT ENFORCED
);


CREATE TABLE DimCampaign (
    campaign_key INT IDENTITY(1,1),
    campaign_id NVARCHAR(50),
    campaign_name NVARCHAR(255),
    channel_key INT,
    active_flag CHAR(1),
    effective_date DATETIME,
    expiry_date DATETIME,
    CONSTRAINT PK_DimCampaign PRIMARY KEY NONCLUSTERED (campaign_key) NOT ENFORCED
);


CREATE TABLE FactCampaignPerformance (
    fact_id INT IDENTITY(1,1),
    campaign_key INT,
    date DATE,
    impressions INT,
    clicks INT,
    spend FLOAT,
    CONSTRAINT PK_FactCampaignPerformance PRIMARY KEY NONCLUSTERED (fact_id) NOT ENFORCED
);


    -- Calculate CTR (Clicks / Impressions * 100)
ALTER TABLE DimCampaign
ADD standardized_campaign_name NVARCHAR(255);

ALTER TABLE FactCampaignPerformance
ADD CTR FLOAT,
    CPC FLOAT;

ALTER TABLE DimChannel
ADD CTR FLOAT,
    CPC FLOAT;


INSERT INTO FactCampaignPerformance (campaign_key, date, impressions, clicks, spend, CTR, CPC)
SELECT 
    dc.campaign_key,
    s.date,
    s.impressions,
    s.clicks,
    s.spend,
    CASE WHEN s.impressions > 0 THEN (s.clicks * 100.0 / s.impressions) ELSE 0 END,
    CASE WHEN s.clicks > 0 THEN (s.spend / s.clicks) ELSE 0 END
FROM stg_CampaignData s
JOIN DimCampaign dc ON s.campaign_id = dc.campaign_id
WHERE dc.active_flag = 'Y';


INSERT INTO DimCampaign (campaign_id, campaign_name, standardized_campaign_name, channel_key, active_flag, effective_date, expiry_date)
SELECT
    s.campaign_id,
    s.campaign_name,
    UPPER(LTRIM(RTRIM(s.campaign_name))),
    dc.channel_key,
    'Y',
    GETDATE(),
    NULL
FROM stg_CampaignData s
JOIN DimChannel dc ON s.channel = dc.channel_name
LEFT JOIN DimCampaign dca ON s.campaign_id = dca.campaign_id
WHERE dca.campaign_id IS NULL;



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.insert_FactCampaignPerformance') AND type IN (N'P'))
DROP PROCEDURE dbo.insert_FactCampaignPerformance;
GO

CREATE PROCEDURE dbo.insert_FactCampaignPerformance
AS
BEGIN
    -- Insert performance data into Fact table
    INSERT INTO FactCampaignPerformance (campaign_key, date, impressions, clicks, spend, CTR, CPC)
    SELECT
        dc.campaign_key,
        s.date,
        ISNULL(s.impressions, 0),
        ISNULL(s.clicks, 0),
        ISNULL(s.spend, 0),
        CASE WHEN ISNULL(s.impressions, 0) > 0 THEN (s.clicks * 100.0 / s.impressions) ELSE 0 END,
        CASE WHEN ISNULL(s.clicks, 0) > 0 THEN (s.spend / s.clicks) ELSE 0 END
    FROM stg_CampaignData s
    JOIN DimCampaign dc
        ON s.campaign_id = dc.campaign_id
    WHERE dc.active_flag = 'Y';
END;


