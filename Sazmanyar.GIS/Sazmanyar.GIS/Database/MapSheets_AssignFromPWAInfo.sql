/*
    MapSheets_AssignFromPWAInfo - جایگذاری همهء پروژه‌های PWAInfo در برگهء 1:50000 خودشان
    ==========================================================================================
    نسخهء 3 (مدل دو جدولی) - تاریخ: 1405/06/30 (2026-09-21)

    هدف: هیچ نقطه‌ای بدون برگه نماند. برای هر پروژهء PWAInfo که Lat/Long دارد، برگهء 1:50000 دربرگیرندهء آن نقطه
          محاسبه می‌شود؛ برگه (اگر نباشد) در dbo.MapSheets و اتصال پروژه در dbo.MapSheetProjects ثبت می‌شود.
          چند پروژه در یک برگه = یک برگه با چند اتصال. برگه/اتصال‌هایی که کارفرما با Shapefile فرستاده دست نمی‌خورند.
    برچسب منبع (@Label) روی همهء سطرهای این اسکریپت می‌نشیند تا بعداً، وقتی دادهء واقعی کارفرما رسید، بشود
    فقط سطرهای محاسبه‌شده را با دستور انتهای اسکریپت حذف کرد.

    قاعدهء شبکهء برگه‌های ایران (از 11 برگهء واقعی راور استخراج و با برگهء تهران 6261 کنترل شد):
      * برگهء 1:100000 چهاررقمی است: دو رقم اول ستون (طول)، دو رقم دوم ردیف (عرض)، هر کدام با گام نیم درجه
            طول شروع = 20 + ستون * 0.5        عرض شروع = 5 + ردیف * 0.5
      * برگهء 1:50000 یک‌چهارم آن (15 دقیقه در 15 دقیقه) با شمارهء ربع: 1 شمال‌شرق، 2 جنوب‌شرق، 3 جنوب‌غرب، 4 شمال‌غرب

    قواعد:
      * هر کد پروژه یک بار (پروژهء چندنوعی چند سطر دارد؛ اولین سطر مبنا است).
      * برگه‌ای که از قبل هست (مثلاً از فایل واقعی راور) دست نمی‌خورد؛ کدی که از قبل به برگه‌ای وصل است دوباره وصل نمی‌شود.
      * همهء سطرهای این اسکریپت (برگه و اتصال) با SourceLayer = @Label علامت می‌خورند تا با دستور انتهای اسکریپت قابل حذف باشند.
      * پروژه‌های بدون Lat/Long یا بدون ProjectCode جایگذاری نمی‌شوند و در گزارش آخر فهرست می‌شوند
        (اتصال در MapSheetProjects به کد پروژه نیاز دارد).
      * نام فارسی برگه = بخش «محل» از نام پروژه (بعد از خط تیره، بدون کد) - فقط برای نمایش؛ نام رسمی برگه نیست.
        اگر چند پروژه در یک برگه بیفتند، نام اولین پروژه (به ترتیب کد) روی برگه می‌نشیند.

    پیش‌نیاز: MapSheets.sql (نسخهء 2) و PWAInfo.sql.
    * سازگار با SQL Server 2012 و بالاتر.
*/

SET NOCOUNT ON;

DECLARE @Batch UNIQUEIDENTIFIER = NEWID();
DECLARE @Label NVARCHAR(100) = N'computed';                                   -- برچسب منبع سطرهای محاسبه‌شده (SourceLayer)
DECLARE @SourceFile NVARCHAR(255) = N'محاسبه از مختصات تقریبی PWAInfo';

------------------------------------------------------------------
-- 1) یک سطر برای هر کد پروژه که مختصات دارد + محاسبهء برگه
------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Cand') IS NOT NULL DROP TABLE #Cand;

;WITH FirstRow AS
(
    SELECT p.*,
           ROW_NUMBER() OVER (PARTITION BY p.ProjectCode ORDER BY p.ID) AS rn
    FROM dbo.PWAInfo p
    WHERE p.ProjectCode IS NOT NULL AND LTRIM(RTRIM(p.ProjectCode)) <> ''
      AND p.Lat IS NOT NULL AND p.[Long] IS NOT NULL
      AND p.Lat BETWEEN 25 AND 40 AND p.[Long] BETWEEN 44 AND 63.5     -- محدودهء ایران
),
Grid AS
(
    SELECT f.*,
           FLOOR(([Long] - 20) / 0.5) AS Col100,
           FLOOR((Lat - 5) / 0.5)     AS Row100
    FROM FirstRow f
    WHERE f.rn = 1
),
Quarter AS
(
    SELECT g.*,
           20 + g.Col100 * 0.5 AS Lon0,
           5  + g.Row100 * 0.5 AS Lat0,
           CASE WHEN g.[Long] >= 20 + g.Col100 * 0.5 + 0.25 THEN 1 ELSE 0 END AS IsEast,
           CASE WHEN g.Lat    >= 5  + g.Row100 * 0.5 + 0.25 THEN 1 ELSE 0 END AS IsNorth
    FROM Grid g
)
SELECT
    q.ProjectCode,
    q.ProjectName,
    q.Region,
    q.ProjectManager,
    q.ProjectSupervisor,
    RIGHT('0' + CAST(q.Col100 AS VARCHAR(4)), 2) + RIGHT('0' + CAST(q.Row100 AS VARCHAR(4)), 2) AS SheetSeries,
    CASE WHEN q.IsEast = 1 AND q.IsNorth = 1 THEN 1
         WHEN q.IsEast = 1 AND q.IsNorth = 0 THEN 2
         WHEN q.IsEast = 0 AND q.IsNorth = 0 THEN 3
         ELSE 4 END AS SheetQuarter,
    CAST(q.Lon0 + CASE WHEN q.IsEast  = 1 THEN 0.25 ELSE 0 END AS DECIMAL(9,6)) AS MinLong,
    CAST(q.Lat0 + CASE WHEN q.IsNorth = 1 THEN 0.25 ELSE 0 END AS DECIMAL(9,6)) AS MinLat,
    -- نام محل از نام پروژه: بخش بعد از آخرین خط تیره، بدون کد پروژه
    LTRIM(RTRIM(REPLACE(
        CASE WHEN CHARINDEX('-', REVERSE(q.ProjectName)) > 0
             THEN RIGHT(q.ProjectName, CHARINDEX('-', REVERSE(q.ProjectName)) - 1)
             ELSE q.ProjectName END,
        q.ProjectCode, ''))) AS PlaceName
INTO #Cand
FROM Quarter q;

ALTER TABLE #Cand ADD SheetNo NVARCHAR(20), MaxLong DECIMAL(9,6), MaxLat DECIMAL(9,6);
UPDATE #Cand SET SheetNo = SheetSeries + '-' + CAST(SheetQuarter AS VARCHAR(1)),
                 MaxLong = MinLong + 0.25,
                 MaxLat  = MinLat  + 0.25;

------------------------------------------------------------------
-- 2) برگه‌ها: یک سطر برای هر شمارهء برگه که هنوز در MapSheets نیست
------------------------------------------------------------------
INSERT INTO dbo.MapSheets
    (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
     Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
     SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
SELECT
    c.SheetNo, 50000, c.SheetSeries, CAST(c.SheetQuarter AS NVARCHAR(4)), NULL, NULL, NULLIF(c.PlaceName, N''),
    -- حلقهء بیرونی: شمال‌شرق، جنوب‌شرق، جنوب‌غرب، شمال‌غرب (همان قالب PolygonPoints)
    N'[{"lat":' + FORMAT(c.MaxLat, '0.000000', 'en-US') + N',"lng":' + FORMAT(c.MaxLong, '0.000000', 'en-US') + N'},' +
    N'{"lat":'  + FORMAT(c.MinLat, '0.000000', 'en-US') + N',"lng":' + FORMAT(c.MaxLong, '0.000000', 'en-US') + N'},' +
    N'{"lat":'  + FORMAT(c.MinLat, '0.000000', 'en-US') + N',"lng":' + FORMAT(c.MinLong, '0.000000', 'en-US') + N'},' +
    N'{"lat":'  + FORMAT(c.MaxLat, '0.000000', 'en-US') + N',"lng":' + FORMAT(c.MinLong, '0.000000', 'en-US') + N'}]',
    4,
    (c.MinLat + c.MaxLat) / 2, (c.MinLong + c.MaxLong) / 2,
    c.MinLat, c.MinLong, c.MaxLat, c.MaxLong,
    -- مساحت تقریبی: 15 دقیقه عرض (27.6 km) در 15 دقیقه طول (27.8 km * cos عرض)
    CAST(0.25 * 110.57 * 0.25 * 111.32 * COS(RADIANS((c.MinLat + c.MaxLat) / 2)) AS DECIMAL(12,3)),
    @SourceFile, @Label, N'GCS_WGS_1984', @Batch, N'assign script'
FROM #Cand c
WHERE c.ProjectCode = (SELECT MIN(x.ProjectCode) FROM #Cand x WHERE x.SheetNo = c.SheetNo)     -- یک سطر برای هر برگه
  AND NOT EXISTS (SELECT 1 FROM dbo.MapSheets m WHERE m.SheetScale = 50000 AND m.SheetNo = c.SheetNo);

PRINT N'برگه‌های ثبت‌شده: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

------------------------------------------------------------------
-- 3) اتصال‌ها: هر کد پروژه به برگه‌اش، مگر از قبل به برگه‌ای وصل باشد
------------------------------------------------------------------
INSERT INTO dbo.MapSheetProjects
    (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes,
     SourceFile, SourceLayer, ImportBatch, ImportedBy)
SELECT
    m.ID, c.ProjectCode, c.ProjectName, c.ProjectManager, c.ProjectSupervisor, NULL,
    N'{"computed":"1","source":"PWAInfo Lat/Long"}',
    @SourceFile, @Label, @Batch, N'assign script'
FROM #Cand c
JOIN dbo.MapSheets m ON m.SheetScale = 50000 AND m.SheetNo = c.SheetNo
WHERE NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects l WHERE l.ProjectCode = c.ProjectCode);

PRINT N'اتصال‌های ثبت‌شده: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N'  (ImportBatch = ' + CAST(@Batch AS NVARCHAR(40)) + N')';

------------------------------------------------------------------
-- 4) گزارش کنترلی
------------------------------------------------------------------
-- 4a) سطرهای PWAInfo که هنوز به هیچ برگه‌ای وصل نیستند و علت آن
SELECT p.ID, p.ProjectName, p.ProjectCode, p.Region, p.Lat, p.[Long],
       CASE WHEN p.ProjectCode IS NULL OR LTRIM(RTRIM(p.ProjectCode)) = '' THEN N'بدون کد پروژه'
            WHEN p.Lat IS NULL OR p.[Long] IS NULL THEN N'بدون مختصات'
            WHEN NOT (p.Lat BETWEEN 25 AND 40 AND p.[Long] BETWEEN 44 AND 63.5) THEN N'مختصات خارج از ایران'
            ELSE N'نامشخص' END AS Reason
FROM dbo.PWAInfo p
WHERE NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects l WHERE l.ProjectCode = p.ProjectCode)
ORDER BY Reason, p.Region, p.ProjectName;

-- 4b) به تفکیک منطقه، و برگه‌های چندپروژه‌ای
SELECT c.Region,
       COUNT(*) AS Projects,
       SUM(CASE WHEN l.ID IS NOT NULL THEN 1 ELSE 0 END) AS WithSheet,
       SUM(CASE WHEN l.ID IS NULL THEN 1 ELSE 0 END) AS WithoutSheet
FROM #Cand c
LEFT JOIN dbo.MapSheetProjects l ON l.ProjectCode = c.ProjectCode
GROUP BY c.Region
ORDER BY c.Region;

SELECT m.SheetNo, m.SheetNameFa, COUNT(*) AS Projects
FROM dbo.MapSheets m JOIN dbo.MapSheetProjects l ON l.SheetID = m.ID
WHERE l.SourceLayer = @Label
GROUP BY m.SheetNo, m.SheetNameFa HAVING COUNT(*) > 1
ORDER BY Projects DESC;

DROP TABLE #Cand;
GO

/* ------------------------------------------------------------------
   حذف همهء سطرهای محاسبه‌شده (برگه‌ها و اتصال‌های واقعی کارفرما دست نمی‌خورند):
   DELETE FROM dbo.MapSheetProjects WHERE SourceLayer = N'computed';
   DELETE FROM dbo.MapSheets WHERE SourceLayer = N'computed'
     AND NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects l WHERE l.SheetID = MapSheets.ID);
   ------------------------------------------------------------------ */
