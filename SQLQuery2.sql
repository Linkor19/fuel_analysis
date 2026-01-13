--CREATE VIEW merged_table AS (
--	SELECT A.*, B.region, B.type_place, B.location, C.range
--	FROM orders A INNER JOIN azsloc B
--	ON A.azs = B.azs
--	INNER JOIN range C
--	ON A.card_pride = C.card_pride
--	)

--DELETE orderss
--WHERE [Номенклатура_пального] IS NULL 
--	AND [ВидРозміщення] IS NULL 
--	AND [Діапазон_карт_лояльності] IS NULL 
--	AND [Область] IS NULL 

--SELECT TOP 1 *
--FROM merged_table

--SELECT [Номенклатура_пального], CAST(COUNT(*) AS FLOAT) / CAST((SELECT COUNT(*) FROM orderss) AS FLOAT)
--FROM orderss
--GROUP BY [Номенклатура_пального]

--SELECT nomenclature, CAST(COUNT(*) AS FLOAT) / CAST((SELECT COUNT(*) FROM merged_table) AS FLOAT)
--FROM merged_table 
--GROUP BY nomenclature



--SELECT SUM(CAST(IsPremial AS FLOAT)) / COUNT(*)
--FROM (
--	SELECT *, 
--		CASE 
--		WHEN [Номенклатура_пального] LIKE '%(Преміум)%'
--		THEN 1
--		ELSE 0
--		END AS IsPremial
--	FROM orderss
--	)Q;

--ALTER TABLE dbo.orderss
--ADD IsPremial AS (
--    CASE 
--        WHEN [Номенклатура_пального] LIKE '%(Преміум)%' THEN 1
--        ELSE 0
--    END
--);

-----------------------------------------------------------------------------------------------------


SELECT SUM(CAST(TotalPremOrders AS FLOAT)) / SUM(TotalAZSOrders), SUM(HypotheticalPremOrders) / SUM(TotalPAZSOrders),
	SUM(CAST(TotalPremOrders AS FLOAT)) / SUM(TotalAZSOrders) - SUM(HypotheticalPremOrders) / SUM(TotalPAZSOrders)
FROM (
	SELECT *, AZSratio - AZSPratio  AS DemandChanges,
		TotalPAZSOrders AS  TotalPAZSOrderss,
		TotalPAZSOrders * PremRatio AS HypotheticalPremOrders
	FROM (
		SELECT [АЗС], COUNT (*) AS TotalAZSOrders, SUM(IsPremial) AS TotalPremOrders,
			CAST(COUNT(*) AS FLOAT) / CAST ((SELECT COUNT(*) FROM orderss) AS FLOAT) AS AZSratio,
			SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) AS PremRatio,
			ROW_NUMBER() OVER (ORDER BY SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) DESC) AS rnk
		FROM orderss 
		GROUP BY [АЗС]
		) A LEFT JOIN (
		SELECT azs, CAST(COUNT(*) AS FLOAT) / CAST ((SELECT COUNT(*) FROM merged_table) AS FLOAT) AS AZSPratio,
			CAST(COUNT(*) AS FLOAT) AS TotalPAZSOrders
		FROM merged_table
		GROUP BY azs
		) B
	ON REPLACE(A.[АЗС], ' ','') = B.azs
	--ORDER BY AZSPratio - AZSratio ASC
	) M 
WHERE azs IS NOT NULL 

SELECT *, AZSratio - AZSPratio  AS DemandChanges,
		TotalPAZSOrders AS  TotalPAZSOrderss,
		TotalPAZSOrders * PremRatio AS HypotheticalPremOrders
	FROM (
		SELECT [АЗС], COUNT (*) AS TotalAZSOrders, SUM(IsPremial) AS TotalPremOrders,
			CAST(COUNT(*) AS FLOAT) / CAST ((SELECT COUNT(*) FROM orderss) AS FLOAT) AS AZSratio,
			SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) AS PremRatio,
			ROW_NUMBER() OVER (ORDER BY SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) DESC) AS rnk
		FROM orderss 
		GROUP BY [АЗС]
		) A LEFT JOIN (
		SELECT azs, CAST(COUNT(*) AS FLOAT) / CAST ((SELECT COUNT(*) FROM merged_table) AS FLOAT) AS AZSPratio,
			CAST(COUNT(*) AS FLOAT) AS TotalPAZSOrders
		FROM merged_table
		GROUP BY azs
		) B
	ON REPLACE(A.[АЗС], ' ','') = B.azs
	ORDER BY AZSPratio - AZSratio ASC



SELECT [ВидРозміщення], COUNT (*) AS TotalDiasplacementOrders, SUM(IsPremial) AS TotalPremOrders,
	CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS DiasplacementRatio,
	SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) AS PremRatio,
	ROW_NUMBER() OVER (ORDER BY SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) DESC) AS rnk
FROM orderss
GROUP BY [ВидРозміщення];

SELECT SUM(CAST(TotalPremOrders AS FLOAT)) / SUM(TotalLocationOrders), SUM(HypotheticalPremOrders) / SUM(TotalPLocationOrderss),
	SUM(CAST(TotalPremOrders AS FLOAT)) / SUM(TotalLocationOrders) - SUM(HypotheticalPremOrders) / SUM(TotalPLocationOrderss)
FROM (
	SELECT *, LocationRatio - LocationPRatio AS DemandChanges,
		TotalPLocationOrders AS TotalPLocationOrderss,
		TotalPLocationOrders * PremRatio AS HypotheticalPremOrders
	FROM (
		SELECT [ЛокаціяВНаселеномуПункті], COUNT (*) AS TotalLocationOrders, SUM(IsPremial) AS TotalPremOrders,
			CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS LocationRatio,
			SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) AS PremRatio,
			ROW_NUMBER() OVER (ORDER BY SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) DESC) AS rnk
		FROM orderss
		GROUP BY [ЛокаціяВНаселеномуПункті]
		) A  LEFT JOIN (
		SELECT location, CAST(COUNT(*) AS FLOAT) / CAST ((SELECT COUNT(*) FROM merged_table) AS FLOAT) AS LocationPRatio,
			CAST(COUNT(*) AS FLOAT) AS TotalPLocationOrders
		FROM merged_table
		GROUP BY location 
		) B
	ON A.[ЛокаціяВНаселеномуПункті] = B.location
	WHERE location IS NOT NULL
	--ORDER BY LocationPRatio - LocationRatio ASC
) Q
WHERE location IS NOT NULL


SELECT SUM(CAST(TotalPremOrders AS FLOAT)) / SUM(TotalDistrictOrders), SUM(HypotheticalPremOrders) / SUM(TotalPDistrictOrders),
	SUM(CAST(TotalPremOrders AS FLOAT)) / SUM(TotalDistrictOrders) - SUM(HypotheticalPremOrders) / SUM(TotalPDistrictOrders)
FROM (
	SELECT *, DistrictRatio - DistrictPRatio  AS DemandChanges,
		TotalPDistrictOrders AS TotalPDistrictOrderss,
		TotalPDistrictOrders * PremRatio AS HypotheticalPremOrders
	FROM (
		SELECT [Область], COUNT (*) AS TotalDistrictOrders, SUM(IsPremial) AS TotalPremOrders,
			CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS DistrictRatio,
			SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) AS PremRatio,
			ROW_NUMBER() OVER (ORDER BY SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) DESC) AS rnk
		FROM orderss
		GROUP BY [Область]
		) A LEFT JOIN (
		SELECT region , CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM merged_table) AS DistrictPRatio,
			CAST(COUNT(*) AS FLOAT) AS TotalPDistrictOrders
		FROM merged_table
		GROUP BY region
		) B
	ON A.[Область]  = B.region
	--ORDER BY DistrictPRatio - DistrictRatio ASC
)Q
WHERE region IS NOT NULL


SELECT SUM(CAST(TotalPremOrders AS FLOAT)) / SUM(TotalCardOrders), SUM(HypotheticalPremOrders) / SUM(TotalPCardOrders),
	SUM(CAST(TotalPremOrders AS FLOAT)) / SUM(TotalCardOrders) - SUM(HypotheticalPremOrders) / SUM(TotalPCardOrders)
FROM (
	SELECT *, CardRatio - CardPRatio AS DemandChanges,
		TotalPCardOrders AS TotalPCardOrderss,
		TotalPCardOrders * PremRatio AS HypotheticalPremOrders
	FROM (
		SELECT [Діапазон_карт_лояльності], COUNT (*) AS TotalCardOrders, SUM(IsPremial) AS TotalPremOrders,
			CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS CardRatio,
			SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) AS PremRatio,
			ROW_NUMBER() OVER (ORDER BY SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) DESC) AS rnk
		FROM orderss
		GROUP BY [Діапазон_карт_лояльності]
		) A LEFT JOIN (
		SELECT range, CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM merged_table) AS CardPRatio,
			CAST(COUNT(*) AS FLOAT) AS TotalPCardOrders
		FROM merged_table
		GROUP BY range
		) B
	ON REPLACE(A.[Діапазон_карт_лояльності],'Діапазон карт ','') = REPLACE(B.range, 'range - ','')
	--ORDER BY CardPRatio - CardRatio ASC
	)Q
WHERE range IS NOT NULL AND TotalCardOrders > 3
	
	

SELECT [ТипРеалізаціїОсновний],COUNT (*) AS TotalPaymentOrders, SUM(IsPremial) AS TotalPremOrders,
	CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS PaymentRatio,
	SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) AS PremRatio,
	ROW_NUMBER() OVER (ORDER BY SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) DESC) AS rnk
FROM orderss
GROUP BY [ТипРеалізаціїОсновний];

SELECT [СпосібПредявленняPride], COUNT (*) AS TotalInfoOrders, SUM(IsPremial) AS TotalPremOrders,
	CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS InfoRatio,
	SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) AS PremRatio,
	ROW_NUMBER() OVER (ORDER BY SUM(CAST(IsPremial AS FLOAT)) / COUNT(*) DESC) AS rnk
FROM orderss
GROUP BY [СпосібПредявленняPride];


----------------------------------------------------------------------------------------------------


--CREATE VIEW orders_before AS (
--	SELECT *
--	FROM orderss 
--	WHERE [дата] < '2024-07-25' 
--	)

--CREATE VIEW orders_after AS (
--	SELECT *
--	FROM orderss 
--	WHERE [дата] > '2024-08-06'
--	)

--SELECT TOP 1 *
--FROM orderss
--WHERE [дата] < '2024-07-25' OR [дата] > '2024-08-06'

--CREATE VIEW orders_during AS (
--	SELECT *
--	FROM orderss
--	WHERE [дата] BETWEEN '2024-07-25' AND '2024-08-06'
--	)

--SELECT TOP 1 *
--FROM orders_after

--SELECT SUM([літри])
--FROM orders_before
--WHERE [дата] > 



--SELECT (
--	SELECT SUM([літри])/ (SELECT COUNT(DISTINCT([дата]))FROM orders_during)
--	FROM orders_during
--	WHERE IsPremial = 1) /
--	(SELECT SUM([літри])/ (SELECT COUNT(DISTINCT([дата]))FROM orders_before)
--	FROM orders_before
--	WHERE IsPremial = 1) - 1

--SELECT (
--	SELECT SUM([літри])/ (SELECT COUNT(DISTINCT([дата]))FROM orders_during)
--	FROM orders_during
--	WHERE IsPremial = 0) /
--	(SELECT SUM([літри])/ (SELECT COUNT(DISTINCT([дата]))FROM orders_before)
--	FROM orders_before
--	WHERE IsPremial = 0) - 1
	 

SELECT (
	SELECT SUM([літри])
	FROM orders_during 
	WHERE IsPremial = 1
	) / (
	SELECT SUM([літри])
	FROM orders_before 
	WHERE IsPremial = 1
	) - 1 AS TrandBefore1
	
SELECT (
	SELECT SUM([літри])
	FROM orders_during 
	WHERE IsPremial = 0
	) / (
	SELECT SUM([літри])
	FROM orders_before 
	WHERE IsPremial = 0
	) - 1 AS TrandBefore0

SELECT 
    (
        SELECT SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) FROM orders_during 
        WHERE IsPremial = 1 
        AND NOT (
             [ВидРозміщення] IN ('ТаможенныйПереход')
             OR [ЛокаціяВНаселеномуПункті] IN ('На трасі', 'Місто') 
             OR [Область] IN ('АЗС - Івано-Франківської області') 
             OR [Діапазон_карт_лояльності] IN ('Діапазон карт 38','Діапазон карт 40', 'Діапазон карт 41')
			 OR [ТипРеалізаціїОсновний] <> 'Гаманець'
        )
    ) / 
    (
        SELECT SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) FROM orders_before 
        WHERE IsPremial = 1 
        AND NOT (

             [ВидРозміщення] IN ('ТаможенныйПереход')
             OR [ЛокаціяВНаселеномуПункті] IN ('На трасі', 'Місто')
             OR [Область] IN ('АЗС - Івано-Франківської області') 
	         OR [Діапазон_карт_лояльності] IN ('Діапазон карт 38','Діапазон карт 40', 'Діапазон карт 41')
			 OR [ТипРеалізаціїОсновний] <> 'Гаманець'
        )
    ) - 1 AS TrandBefore1_Corrected_Exclusion;

    


SELECT AZS1, TrandBefore1 - TrandBefore0 AS TrendBeforeDIFF, TrandAfter1 - TrandAfter0 AS TrandAfterDIFF, AZSRatio,
	AZSRatio * (TrandBefore1 - TrandBefore0) AS FinalMetric,
	ROW_NUMBER() OVER (ORDER BY AZSRatio * (TrandBefore1 - TrandBefore0) DESC) AS rnk,
	TotalLitersDuring - TotalLitersBefore * (1+TrandBefore0)  AS Additional_sold_liters 
FROM (
	SELECT A.[АЗС] AS AZS1, TotalLitersBefore AS StartValue1, 
	TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore1, 
	TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter1, TotalLitersDuring,TotalLitersBefore
	FROM (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 1
		GROUP BY [АЗС]
		) A LEFT JOIN (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 1
		GROUP BY [АЗС] ) B
		ON A.[АЗС] = B.[АЗС]
		LEFT JOIN (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 1
		GROUP BY [АЗС] ) C
		ON A.[АЗС] = C.[АЗС]
		LEFT JOIN (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 1
		GROUP BY [АЗС] ) D
		ON A.[АЗС] = D.[АЗС]
	) A FULL JOIN (
	SELECT A.[АЗС] AS AZS0 , TotalLitersBefore AS StartValue0, TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore0, TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter0
	FROM (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 0
		GROUP BY [АЗС]
		) A LEFT JOIN (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 0
		GROUP BY [АЗС] ) B
		ON A.[АЗС] = B.[АЗС]
		LEFT JOIN (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during)  AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 0
		GROUP BY [АЗС] ) C
		ON A.[АЗС] = C.[АЗС]
		LEFT JOIN (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 0
		GROUP BY [АЗС] ) D
		ON A.[АЗС] = D.[АЗС]
	) B
	ON A.AZS1 = B.AZS0
	FULL JOIN (SELECT [АЗС] AS AZS, CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS AZSRatio FROM orderss GROUP BY [АЗС]) C
	ON A.AZS1 = C.AZS;

SELECT A.[АЗС] AS AZS1, TotalLitersBefore AS StartValue1, 
	TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore1, 
	TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter1, TotalLitersDuring,TotalLitersBefore
	FROM (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 1
		GROUP BY [АЗС]
		) A LEFT JOIN (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 1
		GROUP BY [АЗС] ) B
		ON A.[АЗС] = B.[АЗС]
		LEFT JOIN (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 1
		GROUP BY [АЗС] ) C
		ON A.[АЗС] = C.[АЗС]
		LEFT JOIN (
		SELECT [АЗС], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 1
		GROUP BY [АЗС] ) D
		ON A.[АЗС] = D.[АЗС]
	

SELECT VidRozm1, TrandBefore1 - TrandBefore0 AS TrendBeforeDIFF, TrandAfter1 - TrandAfter0 AS TrandAfterDIFF, VidRozmRatio,
	VidRozmRatio * (TrandBefore1 - TrandBefore0) AS FinalMetric,
	ROW_NUMBER() OVER (ORDER BY VidRozmRatio * (TrandBefore1 - TrandBefore0) DESC) AS rnk,
	TotalLitersDuring - TotalLitersBefore * (1+TrandBefore0)  AS Additional_sold_liters , TrandBefore1, TrandBefore0
FROM (
	SELECT A.[ВидРозміщення] AS VidRozm1, TotalLitersBefore AS StartValue1, TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore1, 
		TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter1, TotalLitersDuring, TotalLitersBefore
	FROM (
		SELECT [ВидРозміщення], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 1
		GROUP BY [ВидРозміщення]
		) A LEFT JOIN (
		SELECT [ВидРозміщення], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 1
		GROUP BY [ВидРозміщення] ) B
		ON A.[ВидРозміщення] = B.[ВидРозміщення]
		LEFT JOIN (
		SELECT [ВидРозміщення], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 1
		GROUP BY [ВидРозміщення] ) C
		ON A.[ВидРозміщення] = C.[ВидРозміщення]
		LEFT JOIN (
		SELECT [ВидРозміщення], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 1
		GROUP BY [ВидРозміщення] ) D
		ON A.[ВидРозміщення] = D.[ВидРозміщення]
	) A FULL JOIN (
	SELECT A.[ВидРозміщення] AS VidRozm0 , TotalLitersBefore AS StartValue0, TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore0, TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter0
	FROM (
		SELECT [ВидРозміщення], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 0
		GROUP BY [ВидРозміщення]
		) A LEFT JOIN (
		SELECT [ВидРозміщення], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 0
		GROUP BY [ВидРозміщення] ) B
		ON A.[ВидРозміщення] = B.[ВидРозміщення]
		LEFT JOIN (
		SELECT [ВидРозміщення], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 0
		GROUP BY [ВидРозміщення] ) C
		ON A.[ВидРозміщення] = C.[ВидРозміщення]
		LEFT JOIN (
		SELECT [ВидРозміщення], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 0
		GROUP BY [ВидРозміщення] ) D
		ON A.[ВидРозміщення] = D.[ВидРозміщення]
	) B
	ON A.VidRozm1 = B.VidRozm0
	FULL JOIN (SELECT [ВидРозміщення] AS VidRozm, CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS VidRozmRatio FROM orderss GROUP BY [ВидРозміщення]) C
	ON A.VidRozm1 = C.VidRozm


SELECT LokVNPU1, TrandBefore1 - TrandBefore0 AS TrendBeforeDIFF, TrandAfter1 - TrandAfter0 AS TrandAfterDIFF, LokRatio,
	LokRatio * (TrandBefore1 - TrandBefore0) AS FinalMetric,
	ROW_NUMBER() OVER (ORDER BY LokRatio * (TrandBefore1 - TrandBefore0) DESC) AS rnk,
	TotalLitersDuring - TotalLitersBefore * (1+TrandBefore0)  AS Additional_sold_liters, TrandBefore1 ,TrandBefore0
FROM (
	SELECT A.[ЛокаціяВНаселеномуПункті] AS LokVNPU1, TotalLitersBefore AS StartValue1, TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore1, 
		TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter1, TotalLitersDuring, TotalLitersBefore
	FROM (
		SELECT [ЛокаціяВНаселеномуПункті], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 1
		GROUP BY [ЛокаціяВНаселеномуПункті]
		) A LEFT JOIN (
		SELECT [ЛокаціяВНаселеномуПункті], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 1
		GROUP BY [ЛокаціяВНаселеномуПункті] ) B
		ON A.[ЛокаціяВНаселеномуПункті] = B.[ЛокаціяВНаселеномуПункті]
		LEFT JOIN (
		SELECT [ЛокаціяВНаселеномуПункті], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 1
		GROUP BY [ЛокаціяВНаселеномуПункті] ) C
		ON A.[ЛокаціяВНаселеномуПункті] = C.[ЛокаціяВНаселеномуПункті]
		LEFT JOIN (
		SELECT [ЛокаціяВНаселеномуПункті], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 1
		GROUP BY [ЛокаціяВНаселеномуПункті] ) D
		ON A.[ЛокаціяВНаселеномуПункті] = D.[ЛокаціяВНаселеномуПункті]
	) A FULL JOIN (
	SELECT A.[ЛокаціяВНаселеномуПункті] AS LokVNPU0 , TotalLitersBefore AS StartValue0, TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore0, TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter0
	FROM (
		SELECT [ЛокаціяВНаселеномуПункті], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 0
		GROUP BY [ЛокаціяВНаселеномуПункті]
		) A LEFT JOIN (
		SELECT [ЛокаціяВНаселеномуПункті], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 0
		GROUP BY [ЛокаціяВНаселеномуПункті] ) B
		ON A.[ЛокаціяВНаселеномуПункті] = B.[ЛокаціяВНаселеномуПункті]
		LEFT JOIN (
		SELECT [ЛокаціяВНаселеномуПункті], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 0
		GROUP BY [ЛокаціяВНаселеномуПункті] ) C
		ON A.[ЛокаціяВНаселеномуПункті] = C.[ЛокаціяВНаселеномуПункті]
		LEFT JOIN (
		SELECT [ЛокаціяВНаселеномуПункті], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 0
		GROUP BY [ЛокаціяВНаселеномуПункті] ) D
		ON A.[ЛокаціяВНаселеномуПункті] = D.[ЛокаціяВНаселеномуПункті]
	) B
	ON A.LokVNPU1 = B.LokVNPU0
	FULL JOIN (SELECT [ЛокаціяВНаселеномуПункті] AS LokVNPU, CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS LokRatio FROM orderss GROUP BY [ЛокаціяВНаселеномуПункті]) C
	ON A.LokVNPU1 = C.LokVNPU


SELECT Oblast1, TrandBefore1 - TrandBefore0 AS TrendBeforeDIFF, TrandAfter1 - TrandAfter0 AS TrandAfterDIFF, OblastRatio, 
	OblastRatio * (TrandBefore1 - TrandBefore0) AS FinalMetric,
	ROW_NUMBER() OVER (ORDER BY OblastRatio * (TrandBefore1 - TrandBefore0) DESC) AS rnk,
	TotalLitersDuring - TotalLitersBefore * (1+TrandBefore0)  AS Additional_sold_liters,TrandBefore1,TrandBefore0
FROM (
	SELECT A.[Область] AS Oblast1, TotalLitersBefore AS StartValue1, TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore1, 
		TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter1, TotalLitersDuring, TotalLitersBefore
	FROM (
		SELECT [Область], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 1
		GROUP BY [Область]
		) A LEFT JOIN (
		SELECT [Область], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 1
		GROUP BY [Область] ) B
		ON A.[Область] = B.[Область]
		LEFT JOIN (
		SELECT [Область], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 1
		GROUP BY [Область] ) C
		ON A.[Область] = C.[Область]
		LEFT JOIN (
		SELECT [Область], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 1
		GROUP BY [Область] ) D
		ON A.[Область] = D.[Область]
	) A FULL JOIN (
	SELECT A.[Область] AS Oblast0 , TotalLitersBefore AS StartValue0, TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore0, TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter0
	FROM (
		SELECT [Область], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 0
		GROUP BY [Область]
		) A LEFT JOIN (
		SELECT [Область], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 0
		GROUP BY [Область] ) B
		ON A.[Область] = B.[Область]
		LEFT JOIN (
		SELECT [Область], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 0
		GROUP BY [Область] ) C
		ON A.[Область] = C.[Область]
		LEFT JOIN (
		SELECT [Область], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 0
		GROUP BY [Область] ) D
		ON A.[Область] = D.[Область]
	) B
	ON A.Oblast1 = B.Oblast0
	FULL JOIN (SELECT [Область] AS Oblast, CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS OblastRatio FROM orderss GROUP BY [Область]) C
	ON A.Oblast1 = C.Oblast

SELECT DiapazonKL1, TrandBefore1 - TrandBefore0 AS TrendBeforeDIFF, TrandAfter1 - TrandAfter0 AS TrandAfterDIFF, DiapazonKLRatio,
	DiapazonKLRatio * (TrandBefore1 - TrandBefore0) AS FinalMetric,
	ROW_NUMBER() OVER (ORDER BY DiapazonKLRatio * (TrandBefore1 - TrandBefore0) DESC) AS rnk,
	TotalLitersDuring - TotalLitersBefore * (1+TrandBefore0)  AS Additional_sold_liters, TrandBefore1, TrandBefore0
FROM (
	SELECT A.[Діапазон_карт_лояльності] AS DiapazonKL1, TotalLitersBefore AS StartValue1,
		TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore1, 
		TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter1, TotalLitersDuring, TotalLitersBefore
	FROM (
		SELECT [Діапазон_карт_лояльності], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 1
		GROUP BY [Діапазон_карт_лояльності]
		) A LEFT JOIN (
		SELECT [Діапазон_карт_лояльності], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 1
		GROUP BY [Діапазон_карт_лояльності] ) B
		ON A.[Діапазон_карт_лояльності] = B.[Діапазон_карт_лояльності]
		LEFT JOIN (
		SELECT [Діапазон_карт_лояльності], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 1
		GROUP BY [Діапазон_карт_лояльності] ) C
		ON A.[Діапазон_карт_лояльності] = C.[Діапазон_карт_лояльності]
		LEFT JOIN (
		SELECT [Діапазон_карт_лояльності], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 1
		GROUP BY [Діапазон_карт_лояльності] ) D
		ON A.[Діапазон_карт_лояльності] = D.[Діапазон_карт_лояльності]
	) A FULL JOIN (
	SELECT A.[Діапазон_карт_лояльності] AS DiapazonKL0 , TotalLitersBefore AS StartValue0, TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore0, TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter0
	FROM (
		SELECT [Діапазон_карт_лояльності], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 0
		GROUP BY [Діапазон_карт_лояльності]
		) A LEFT JOIN (
		SELECT [Діапазон_карт_лояльності], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 0
		GROUP BY [Діапазон_карт_лояльності] ) B
		ON A.[Діапазон_карт_лояльності] = B.[Діапазон_карт_лояльності]
		LEFT JOIN (
		SELECT [Діапазон_карт_лояльності], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 0
		GROUP BY [Діапазон_карт_лояльності] ) C
		ON A.[Діапазон_карт_лояльності] = C.[Діапазон_карт_лояльності]
		LEFT JOIN (
		SELECT [Діапазон_карт_лояльності], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 0
		GROUP BY [Діапазон_карт_лояльності] ) D
		ON A.[Діапазон_карт_лояльності] = D.[Діапазон_карт_лояльності]
	) B
	ON A.DiapazonKL1 = B.DiapazonKL0
	FULL JOIN (SELECT [Діапазон_карт_лояльності] AS DiapazonKL, CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS DiapazonKLRatio FROM orderss GROUP BY [Діапазон_карт_лояльності]) C
	ON A.DiapazonKL1 = C.DiapazonKL

SELECT TypRealOsn1, TrandBefore1 - TrandBefore0 AS TrendBeforeDIFF, TrandAfter1 - TrandAfter0 AS TrandAfterDIFF, TypRealOsnRatio,
	TypRealOsnRatio * (TrandBefore1 - TrandBefore0) AS FinalMetric,
	ROW_NUMBER() OVER (ORDER BY TypRealOsnRatio * (TrandBefore1 - TrandBefore0) DESC) AS rnk,
	TotalLitersDuring - TotalLitersBefore * (1+TrandBefore0)  AS Additional_sold_liters,
	TrandBefore1, TrandBefore0
FROM (
	SELECT A.[ТипРеалізаціїОсновний] AS TypRealOsn1, TotalLitersBefore AS StartValue1, 
		TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore1,
		TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter1, TotalLitersDuring, TotalLitersBefore
	FROM (
		SELECT [ТипРеалізаціїОсновний], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 1
		GROUP BY [ТипРеалізаціїОсновний]
		) A LEFT JOIN (
		SELECT [ТипРеалізаціїОсновний], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 1
		GROUP BY [ТипРеалізаціїОсновний] ) B
		ON A.[ТипРеалізаціїОсновний] = B.[ТипРеалізаціїОсновний]
		LEFT JOIN (
		SELECT [ТипРеалізаціїОсновний], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 1
		GROUP BY [ТипРеалізаціїОсновний] ) C
		ON A.[ТипРеалізаціїОсновний] = C.[ТипРеалізаціїОсновний]
		LEFT JOIN (
		SELECT [ТипРеалізаціїОсновний], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 1
		GROUP BY [ТипРеалізаціїОсновний] ) D
		ON A.[ТипРеалізаціїОсновний] = D.[ТипРеалізаціїОсновний]
	) A FULL JOIN (
	SELECT A.[ТипРеалізаціїОсновний] AS TypRealOsn0 , TotalLitersBefore AS StartValue0, TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore0, TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter0
	FROM (
		SELECT [ТипРеалізаціїОсновний], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 0
		GROUP BY [ТипРеалізаціїОсновний]
		) A LEFT JOIN (
		SELECT [ТипРеалізаціїОсновний], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 0
		GROUP BY [ТипРеалізаціїОсновний] ) B
		ON A.[ТипРеалізаціїОсновний] = B.[ТипРеалізаціїОсновний]
		LEFT JOIN (
		SELECT [ТипРеалізаціїОсновний], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 0
		GROUP BY [ТипРеалізаціїОсновний] ) C
		ON A.[ТипРеалізаціїОсновний] = C.[ТипРеалізаціїОсновний]
		LEFT JOIN (
		SELECT [ТипРеалізаціїОсновний], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 0
		GROUP BY [ТипРеалізаціїОсновний] ) D
		ON A.[ТипРеалізаціїОсновний] = D.[ТипРеалізаціїОсновний]
	) B
	ON A.TypRealOsn1 = B.TypRealOsn0
	FULL JOIN (SELECT [ТипРеалізаціїОсновний] AS TypRealOsn, CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS TypRealOsnRatio FROM orderss GROUP BY [ТипРеалізаціїОсновний]) C
	ON A.TypRealOsn1 = C.TypRealOsn

SELECT SpPrPride1, TrandBefore1 - TrandBefore0 AS TrendBeforeDIFF, TrandAfter1 - TrandAfter0 AS TrandAfterDIFF, SpPrPrideRatio,
	SpPrPrideRatio * (TrandBefore1 - TrandBefore0) AS FinalMetric,
	ROW_NUMBER() OVER (ORDER BY SpPrPrideRatio * (TrandBefore1 - TrandBefore0) DESC) AS rnk,
	TotalLitersDuring - TotalLitersBefore * (1+TrandBefore0)  AS Additional_sold_liters, TrandBefore1, TrandBefore0
FROM ( 
	SELECT A.[СпосібПредявленняPride] AS SpPrPride1, TotalLitersBefore AS StartValue1,
		TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore1, 
		TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter1, TotalLitersDuring, TotalLitersBefore
	FROM (
		SELECT [СпосібПредявленняPride], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 1
		GROUP BY [СпосібПредявленняPride]
		) A LEFT JOIN (
		SELECT [СпосібПредявленняPride], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 1
		GROUP BY [СпосібПредявленняPride] ) B
		ON A.[СпосібПредявленняPride] = B.[СпосібПредявленняPride]
		LEFT JOIN (
		SELECT [СпосібПредявленняPride], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 1
		GROUP BY [СпосібПредявленняPride] ) C
		ON A.[СпосібПредявленняPride] = C.[СпосібПредявленняPride]
		LEFT JOIN (
		SELECT [СпосібПредявленняPride], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 1
		GROUP BY [СпосібПредявленняPride] ) D
		ON A.[СпосібПредявленняPride] = D.[СпосібПредявленняPride]
	) A FULL JOIN (
	SELECT A.[СпосібПредявленняPride] AS SpPrPride0 , TotalLitersBefore AS StartValue0, TotalLitersDuring / TotalLitersBefore - 1 AS TrandBefore0, TotalLitersAfter / TotalLitersDuring - 1 AS TrandAfter0
	FROM (
		SELECT [СпосібПредявленняPride], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orderss) AS TotalLiters
		FROM orderss
		WHERE IsPremial = 0
		GROUP BY [СпосібПредявленняPride]
		) A LEFT JOIN (
		SELECT [СпосібПредявленняPride], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_before) AS TotalLitersBefore
		FROM orders_before
		WHERE IsPremial = 0
		GROUP BY [СпосібПредявленняPride] ) B
		ON A.[СпосібПредявленняPride] = B.[СпосібПредявленняPride]
		LEFT JOIN (
		SELECT [СпосібПредявленняPride], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_during) AS TotalLitersDuring
		FROM orders_during
		WHERE IsPremial = 0
		GROUP BY [СпосібПредявленняPride] ) C
		ON A.[СпосібПредявленняPride] = C.[СпосібПредявленняPride]
		LEFT JOIN (
		SELECT [СпосібПредявленняPride], SUM([літри])/(SELECT COUNT(DISTINCT([дата]))FROM orders_after) AS TotalLitersAfter
		FROM orders_after
		WHERE IsPremial = 0
		GROUP BY [СпосібПредявленняPride] ) D
		ON A.[СпосібПредявленняPride] = D.[СпосібПредявленняPride]
	) B
	ON A.SpPrPride1 = B.SpPrPride0
	FULL JOIN (SELECT [СпосібПредявленняPride] AS SpPrPride, CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM orderss) AS SpPrPrideRatio FROM orderss GROUP BY [СпосібПредявленняPride]) C
	ON A.SpPrPride1 = C.SpPrPride

