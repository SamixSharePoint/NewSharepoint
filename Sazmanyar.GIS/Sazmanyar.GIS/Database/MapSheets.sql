/*
    MapSheets - برگه‌های نقشه (سطح واقعی پروژه‌های PWA)
    ===================================================================
    تاریخ تولید اسکریپت: 1405/06/29 (2026-09-20)

    چرا این جدول؟
      کارفرما محدودهء واقعی بعضی پروژه‌ها را به‌صورت Shapefile می‌فرستد (مثلاً Database\Ravar-map\Ravar2.*:
      یازده برگهء زمین‌شناسی 1:50000 طرح تحول راور). هر برگه یک چهارگوش ثابت جغرافیایی است و پروژه
      کاری است که روی آن برگه انجام می‌شود. بنابراین:
        * موجودیت این جدول «برگه» است و کلید طبیعی آن شمارهء برگه (SheetNo) + مقیاس است.
        * ستون ProjectCode فقط پل اتصال به dbo.PWAInfo.ProjectCode است (کارفرما آن را در ستون P_Code
          فایل پر می‌کند). ProjectCode در PWAInfo یکتا نیست (پروژهء چندنوعی = چند سطر)؛ join از سمت
          MapSheets به همهء آن سطرها می‌رسد و این طبیعی است.
        * هندسه در زمان Import به WGS84 تبدیل و به‌صورت JSON ذخیره می‌شود
          (همان قالب PolygonPoints لیست «لیست سطح ها»: [{"lat":31.37,"lng":56.87},...]) تا کد
          رسم فعلی (GPolygon) بدون تبدیل بتواند آن را بکشد.
        * MapSheets جایگزین Lat/Long تقریبی PWAInfo نمی‌شود؛ روی آن سوار می‌شود. پروژه‌ای که این‌جا
          برگه دارد با مرز واقعی و پین روی مرکز برگه نمایش داده می‌شود و بقیه مثل قبل.

    پرکردن جدول:
      * وب‌پارت ShowAllMapSheetInfo (پنل «ثبت برگه»): فایل ZIP شامل shp/dbf/prj/cpg را می‌گیرد، می‌خواند و
        با upsert روی (SheetScale, SheetNo) ثبت می‌کند. هر Import یک ImportBatch (GUID) می‌گیرد تا
        بتوان یک Import اشتباه را یک‌جا حذف کرد.
      * برای تست بدون وب‌پارت: Database\MapSheets_Seed_Ravar2.sql (خروجی همان فایل کارفرما).

    نگاشت ستون‌های dbf (فایل Ravar2) به جدول:
      N50          -> SheetNo         (7352-1)          ID           -> SourceSheetID
      NO50         -> SheetSeries     (7352)            EN_NAME_50   -> SheetNameEn
      N1_4         -> SheetQuarter    (1..4)            name_farsi   -> SheetNameFa
      P_Code       -> ProjectCode     (پل به PWAInfo)   P_Name       -> ProjectName
      مجری         -> Contractor       ناظر -> Supervisor       زمین -> Geologist
      سایر ستون‌ها -> ExtraAttributes (JSON) تا چیزی گم نشود.

    * اجرای مجدد این اسکریپت داده‌های جدول را از بین نمی‌برد (جدول فقط اگر نباشد ساخته می‌شود)؛
      نما (View) هر بار از نو ساخته می‌شود تا تغییرات ستون‌ها اعمال شود.
    * سازگار با SQL Server 2012 و بالاتر.
*/

SET NOCOUNT ON;
GO

IF OBJECT_ID(N'dbo.MapSheets', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MapSheets
    (
        ------------------------------------------------------------------
        -- هویت برگه
        ------------------------------------------------------------------
        ID                  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MapSheets PRIMARY KEY,
        SheetNo             NVARCHAR(20)    NOT NULL,           -- شمارهء برگه (N50: 7352-1)
        SheetScale          INT             NOT NULL            -- مخرج مقیاس: 50000 / 100000 / 25000
                            CONSTRAINT DF_MapSheets_SheetScale DEFAULT (50000),
        SheetSeries         NVARCHAR(10)    NULL,               -- برگهء مادر 1:100000 (NO50: 7352)
        SheetQuarter        NVARCHAR(4)     NULL,               -- ربع برگه (N1_4: 1..4)
        SourceSheetID       BIGINT          NULL,               -- شناسهء برگه در لایهء index_50 سازمان (ID)
        SheetNameEn         NVARCHAR(100)   NULL,               -- EN_NAME_50
        SheetNameFa         NVARCHAR(100)   NULL,               -- name_farsi

        ------------------------------------------------------------------
        -- اتصال به پروژهء PWA (اطلاعات کارفرما در فایل)
        ------------------------------------------------------------------
        ProjectCode         VARCHAR(20)     NULL,               -- P_Code  -> dbo.PWAInfo.ProjectCode
        ProjectName         NVARCHAR(200)   NULL,               -- P_Name  (نام پروژه به روایت فایل کارفرما)
        Contractor          NVARCHAR(100)   NULL,               -- مجری
        Supervisor          NVARCHAR(100)   NULL,               -- ناظر
        Geologist           NVARCHAR(100)   NULL,               -- زمین‌شناس مسئول («زمین» در فایل)

        ------------------------------------------------------------------
        -- هندسه (WGS84، درجهء اعشاری)
        ------------------------------------------------------------------
        Boundary            NVARCHAR(MAX)   NOT NULL,           -- حلقهء بیرونی: [{"lat":..,"lng":..},...]
        VertexCount         INT             NULL,               -- تعداد رئوس حلقه
        CentroidLat         DECIMAL(9,6)    NULL,               -- مرکز برگه (محل پین)
        CentroidLong        DECIMAL(9,6)    NULL,
        MinLat              DECIMAL(9,6)    NULL,               -- مستطیل محیطی (برای فیت‌کردن نقشه و جستجوی مکانی ساده)
        MinLong             DECIMAL(9,6)    NULL,
        MaxLat              DECIMAL(9,6)    NULL,
        MaxLong             DECIMAL(9,6)    NULL,
        AreaKm2             DECIMAL(12,3)   NULL,               -- مساحت تقریبی (کیلومتر مربع)

        ------------------------------------------------------------------
        -- منشأ و ردگیری Import
        ------------------------------------------------------------------
        ExtraAttributes     NVARCHAR(MAX)   NULL,               -- JSON سایر ستون‌های dbf که نگاشت مستقیم ندارند
        SourceFile          NVARCHAR(255)   NULL,               -- نام ZIP آپلودشده
        SourceLayer         NVARCHAR(100)   NULL,               -- نام shp داخل ZIP (Ravar2)
        SourceCrs           NVARCHAR(200)   NULL,               -- سیستم مختصات اصلی (WGS_1984_UTM_Zone_40N)
        ImportBatch         UNIQUEIDENTIFIER NOT NULL,          -- شناسهء هر بار Import
        ImportedAt          DATETIME        NOT NULL CONSTRAINT DF_MapSheets_ImportedAt DEFAULT (GETDATE()),
        ImportedBy          NVARCHAR(100)   NULL,               -- کاربر SharePoint
        UpdatedAt           DATETIME        NULL,               -- آخرین بازنویسی (Import مجدد همان برگه)

        CONSTRAINT CK_MapSheets_SheetNo CHECK (LEN(LTRIM(RTRIM(SheetNo))) > 0)
    );

    -- کلید طبیعی: یک برگه در هر مقیاس فقط یک بار
    CREATE UNIQUE INDEX UX_MapSheets_Scale_SheetNo ON dbo.MapSheets (SheetScale, SheetNo);
    CREATE INDEX IX_MapSheets_ProjectCode ON dbo.MapSheets (ProjectCode);
    CREATE INDEX IX_MapSheets_ImportBatch ON dbo.MapSheets (ImportBatch);
END
GO

------------------------------------------------------------------
-- نمای اتصال برگه به پروژهء PWA
-- هر برگه یک سطر؛ اطلاعات پروژه از اولین سطر PWAInfo با همان کد (پروژهء چندنوعی چند سطر دارد،
-- تعداد آن‌ها در PwaRowCount می‌آید تا وب‌پارت بداند). اگر کدی در PWAInfo نباشد ستون‌های PWA خالی‌اند.
-- ستون‌های این نما همان شناسه‌های فیلترهای جستجوی پیشرفته (Filter\js\demo_widgetsMapSheet.js) هستند.
------------------------------------------------------------------
IF OBJECT_ID(N'dbo.vw_MapSheetsProjects', N'V') IS NOT NULL
    DROP VIEW dbo.vw_MapSheetsProjects;
GO

CREATE VIEW dbo.vw_MapSheetsProjects
AS
SELECT
    ms.ID, ms.SheetNo, ms.SheetScale, ms.SheetSeries, ms.SheetQuarter, ms.SourceSheetID,
    ms.SheetNameEn, ms.SheetNameFa,
    ms.ProjectCode, ms.ProjectName AS SheetProjectName, ms.Contractor, ms.Supervisor, ms.Geologist,
    ms.Boundary, ms.VertexCount, ms.CentroidLat, ms.CentroidLong, ms.MinLat, ms.MinLong, ms.MaxLat, ms.MaxLong, ms.AreaKm2,
    ms.ExtraAttributes, ms.SourceFile, ms.SourceLayer, ms.SourceCrs, ms.ImportBatch, ms.ImportedAt, ms.ImportedBy, ms.UpdatedAt,
    pwa.PwaRowCount,
    p.ID AS PwaID, p.ProjectName, p.Status, p.PlannedProgress, p.ActualProgress, p.AchievementPct,
    p.StartDateJ, p.StartDate, p.FinishDateJ, p.FinishDate, p.PlannedStartJ, p.PlannedStart, p.PlannedFinishJ, p.PlannedFinish, p.TotalCost,
    p.ProjectType, p.Region, p.ExecutionMethod, p.ProjectManager, p.ProjectSupervisor, p.OrgLevel1, p.OrgLevel2,
    p.Lat AS PwaLat, p.[Long] AS PwaLong, p.TahaghoghCategory
FROM dbo.MapSheets ms
OUTER APPLY (SELECT COUNT(*) AS PwaRowCount FROM dbo.PWAInfo x WHERE x.ProjectCode = ms.ProjectCode) pwa
OUTER APPLY (SELECT TOP 1 * FROM dbo.PWAInfo y WHERE y.ProjectCode = ms.ProjectCode ORDER BY y.ID) p;
GO

/* =====================================================================
   پرس‌وجوهای کنترلی
   ===================================================================== */

-- 1: برگه‌هایی که کد پروژه‌شان در PWAInfo نیست (باید به کارفرما گزارش شود)
SELECT SheetNo, SheetNameFa, ProjectCode, SourceFile
FROM dbo.vw_MapSheetsProjects
WHERE ProjectCode IS NULL OR PwaRowCount = 0
ORDER BY SheetNo;

-- 2: مقایسهء مختصات تقریبی PWAInfo با مرکز واقعی برگه (کیلومتر، تقریبی)
SELECT SheetNo, SheetNameFa, ProjectCode, Region,
       CentroidLat, CentroidLong, PwaLat, PwaLong,
       CAST(SQRT(SQUARE((CentroidLat - PwaLat) * 111.0) + SQUARE((CentroidLong - PwaLong) * 111.0 * COS(RADIANS(CentroidLat)))) AS DECIMAL(8,1)) AS DistKm
FROM dbo.vw_MapSheetsProjects
WHERE PwaLat IS NOT NULL
ORDER BY DistKm DESC;

-- 3: خلاصهء هر Import
SELECT ImportBatch, MIN(ImportedAt) AS ImportedAt, MAX(ImportedBy) AS ImportedBy, MAX(SourceFile) AS SourceFile,
       COUNT(*) AS Sheets, SUM(CASE WHEN ProjectCode IS NULL THEN 1 ELSE 0 END) AS WithoutCode
FROM dbo.MapSheets
GROUP BY ImportBatch
ORDER BY MIN(ImportedAt) DESC;
GO
