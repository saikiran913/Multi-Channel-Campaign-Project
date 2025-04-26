-- Query 1: CTR, CPC, Total Spend, Total Impressions, Total Clicks

SELECT 
    SUM(spend) AS Total_Spend,
    SUM(impressions) AS Total_Impressions,
    SUM(clicks) AS Total_Clicks,
    CASE 
        WHEN SUM(impressions) > 0 THEN (SUM(clicks) * 100.0 / SUM(impressions))
        ELSE 0
    END AS Overall_CTR_Percentage,
    CASE 
        WHEN SUM(clicks) > 0 THEN (SUM(spend) / SUM(clicks))
        ELSE 0
    END AS Overall_CPC
FROM FactCampaignPerformance;

 Step 2: Spend by Channel

SELECT 
    dch.channel_name,
    SUM(fcp.spend) AS Total_Spend
FROM FactCampaignPerformance fcp
JOIN DimCampaign dca ON fcp.campaign_key = dca.campaign_key
JOIN DimChannel dch ON dca.channel_key = dch.channel_key
WHERE dch.active_flag = 'Y'
  AND dca.active_flag = 'Y'
GROUP BY dch.channel_name
ORDER BY Total_Spend DESC;


-- Query 3: CTR (%) per Channel
SELECT 
    dch.channel_name,
    SUM(fcp.impressions) AS Total_Impressions,
    SUM(fcp.clicks) AS Total_Clicks,
    CASE 
        WHEN SUM(fcp.impressions) > 0 THEN (SUM(fcp.clicks) * 100.0 / SUM(fcp.impressions))
        ELSE 0
    END AS CTR_Percentage
FROM FactCampaignPerformance fcp
JOIN DimCampaign dca ON fcp.campaign_key = dca.campaign_key
JOIN DimChannel dch ON dca.channel_key = dch.channel_key
WHERE dch.active_flag = 'Y'
  AND dca.active_flag = 'Y'
GROUP BY dch.channel_name
ORDER BY CTR_Percentage DESC;

--Query 4; Top 10 Campaigns by Total Spend

SELECT TOP 10
    dca.campaign_name,
    SUM(fcp.spend) AS Total_Spend,
    SUM(fcp.impressions) AS Total_Impressions,
    SUM(fcp.clicks) AS Total_Clicks,
    CASE 
        WHEN SUM(fcp.impressions) > 0 THEN (SUM(fcp.clicks) * 100.0 / SUM(fcp.impressions))
        ELSE 0
    END AS CTR_Percentage
FROM FactCampaignPerformance fcp
JOIN DimCampaign dca ON fcp.campaign_key = dca.campaign_key
WHERE dca.active_flag = 'Y'
GROUP BY dca.campaign_name
ORDER BY Total_Spend DESC;


--Query 5 ;Spend and Clicks per Day

SELECT 
    date,
    SUM(spend) AS Daily_Spend,
    SUM(clicks) AS Daily_Clicks
FROM FactCampaignPerformance
GROUP BY date
ORDER BY date ASC;






