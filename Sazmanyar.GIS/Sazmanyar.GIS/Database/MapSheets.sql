/*
    MapSheets + MapSheetProjects - برگه‌های نقشه و اتصال آن‌ها به پروژه‌های PWA
    ===================================================================
    نسخهء 2 - تاریخ: 1405/06/30 (2026-09-21)

    مدل داده (دو جدول):
      * dbo.MapSheets        = لایهء جغرافیایی خالص. هر برگه یک بار، با هندسهء ثابت (WGS84، JSON حلقهء بیرونی)،
                                مستقل از این‌که چه پروژه‌ای روی آن است. کلید طبیعی: مقیاس + شمارهء برگه.
                                می‌تواند بعداً با شاخص کل کشور (index_50) پر شود؛ برگهء بدون پروژه در نقشه کشیده نمی‌شود.
      * dbo.MapSheetProjects = جدول واسط «پروژه روی برگه». هر سطر یک جفت (برگه، کد پروژهء PWA) با صفت‌هایی که کارفرما
                                به ازای همان پروژه روی همان برگه می‌دهد (نام پروژه در فایل، مجری، ناظر، زمین‌شناس).
                                کلید طبیعی: برگه + کد پروژه. بارگذاری‌ها و به‌روزرسانی‌ها عمدتاً روی همین جدول اتفاق می‌افتد.
      * dbo.vw_MapSheetsProjects = یک سطر برای هر جفت برگه‌ـ‌پروژه + اولین سطر PWAInfo با همان کد (PwaRowCount تعداد
                                سطرها). وب‌پارت‌ها فقط از این نما می‌خوانند، پس برگه‌های بدون اتصال هرگز نمایش داده نمی‌شوند.
      * dbo.vw_MapSheetsProjectsAll = همان ستون‌ها ولی یک سطر برای هر «اتصال × سطر PWAInfo» (پروژهء چندنوعی چند سطر).
                                فقط برای ارزیابی شرط جستجوی پیشرفته با EXISTS روی LinkID استفاده می‌شود، تا شرطی مثل
                                «نوع پروژه = ژئوشیمی» روی همهء سطرهای پروژه بررسی شود نه فقط سطر اول.

    چرا این تقسیم؟ فایل راور (Database\Ravar-map) هر برگه را با یک پروژه داده بود، ولی در واقعیت روی یک برگه
    می‌تواند چند پروژه (ژئوشیمی، زمین‌شناسی...) با کدهای متفاوت باشد و یک پروژه چند برگه داشته باشد. نسخهء 1 این
    جدول (کد پروژه به‌عنوان ستون برگه) این را نمی‌پذیرفت.

    پرکردن:
      * وب‌پارت ShowAllMapSheetInfo (پنل «ثبت برگه»): ZIP شامل shp/dbf/prj/cpg -> upsert برگه، سپس upsert اتصال به P_Code.
        هر بارگذاری یک ImportBatch (GUID) دارد؛ حذف بارگذاری اتصال‌های آن را برمی‌دارد و برگه‌هایی را که دیگر اتصالی
        ندارند و از همان بارگذاری آمده‌اند پاک می‌کند.
      * Database\MapSheets_Seed_Ravar2.sql       : 11 برگهء واقعی راور (تست بدون ZIP)
      * Database\MapSheets_AssignFromPWAInfo.sql : برگهء محاسبه‌شده برای همهء پروژه‌های PWAInfo (برچسب computed)

    نگاشت ستون‌های dbf (فایل Ravar2):
      برگه:   N50 -> SheetNo   NO50 -> SheetSeries   N1_4 -> SheetQuarter   ID -> SourceSheetID   EN_NAME_50 / name_farsi -> نام‌ها
      اتصال:  P_Code -> ProjectCode   P_Name -> ProjectName   مجری -> Contractor   ناظر -> Supervisor   زمین -> Geologist
      سایر ستون‌ها -> MapSheetProjects.ExtraAttributes (JSON)

    مهاجرت: اگر جدول نسخهء 1 (با ستون ProjectCode) وجود داشته باشد، به dbo.MapSheets_v1 تغییر نام می‌دهد و داده‌هایش
    به دو جدول جدید منتقل می‌شود. جدول قدیمی برای اطمینان می‌ماند و می‌توان بعداً حذفش کرد (انتهای اسکریپت).
    اجرای مجدد اسکریپت داده را از بین نمی‌برد؛ نما هر بار از نو ساخته می‌شود.
    * سازگار با SQL Server 2012 و بالاتر.
*/

SET NOCOUNT ON;
GO

------------------------------------------------------------------
-- 0) مهاجرت از نسخهء 1: جدول قدیمی کنار گذاشته می‌شود
------------------------------------------------------------------
IF OBJECT_ID(N'dbo.MapSheets', N'U') IS NOT NULL AND COL_LENGTH(N'dbo.MapSheets', N'ProjectCode') IS NOT NULL
BEGIN
    IF OBJECT_ID(N'dbo.vw_MapSheetsProjectsAll', N'V') IS NOT NULL DROP VIEW dbo.vw_MapSheetsProjectsAll;
    IF OBJECT_ID(N'dbo.vw_MapSheetsProjects', N'V') IS NOT NULL DROP VIEW dbo.vw_MapSheetsProjects;
    IF OBJECT_ID(N'dbo.MapSheets_v1', N'U') IS NOT NULL DROP TABLE dbo.MapSheets_v1;
    EXEC sp_rename N'dbo.MapSheets', N'MapSheets_v1';
    IF OBJECT_ID(N'dbo.PK_MapSheets', N'PK') IS NOT NULL EXEC sp_rename N'dbo.PK_MapSheets', N'PK_MapSheets_v1';
    IF OBJECT_ID(N'dbo.DF_MapSheets_SheetScale', N'D') IS NOT NULL EXEC sp_rename N'dbo.DF_MapSheets_SheetScale', N'DF_MapSheets_v1_SheetScale';
    IF OBJECT_ID(N'dbo.DF_MapSheets_ImportedAt', N'D') IS NOT NULL EXEC sp_rename N'dbo.DF_MapSheets_ImportedAt', N'DF_MapSheets_v1_ImportedAt';
    IF OBJECT_ID(N'dbo.CK_MapSheets_SheetNo', N'C') IS NOT NULL EXEC sp_rename N'dbo.CK_MapSheets_SheetNo', N'CK_MapSheets_v1_SheetNo';
    IF OBJECT_ID(N'dbo.UQ_MapSheets_SheetNo', N'C') IS NOT NULL EXEC sp_rename N'dbo.UQ_MapSheets_SheetNo', N'CK_MapSheets_v1_SheetNo_b';
    PRINT N'جدول نسخهء 1 به dbo.MapSheets_v1 تغییر نام داد.';
END
GO

------------------------------------------------------------------
-- 1) برگه‌ها
------------------------------------------------------------------
IF OBJECT_ID(N'dbo.MapSheets', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MapSheets
    (
        ID                  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MapSheets PRIMARY KEY,
        SheetNo             NVARCHAR(20)    NOT NULL,           -- شمارهء برگه (N50: 7352-1)
        SheetScale          INT             NOT NULL            -- مخرج مقیاس: 50000 / 100000 / 25000
                            CONSTRAINT DF_MapSheets_SheetScale DEFAULT (50000),
        SheetSeries         NVARCHAR(10)    NULL,               -- برگهء مادر 1:100000 (NO50: 7352)
        SheetQuarter        NVARCHAR(4)     NULL,               -- ربع برگه (N1_4: 1..4)
        SourceSheetID       BIGINT          NULL,               -- شناسهء برگه در لایهء index_50 سازمان (ID)
        SheetNameEn         NVARCHAR(100)   NULL,               -- EN_NAME_50
        SheetNameFa         NVARCHAR(100)   NULL,               -- name_farsi

        -- هندسه (WGS84، درجهء اعشاری)
        Boundary            NVARCHAR(MAX)   NOT NULL,           -- حلقهء بیرونی: [{"lat":..,"lng":..},...]
        VertexCount         INT             NULL,
        CentroidLat         DECIMAL(9,6)    NULL,               -- مرکز برگه (محل پین)
        CentroidLong        DECIMAL(9,6)    NULL,
        MinLat              DECIMAL(9,6)    NULL,
        MinLong             DECIMAL(9,6)    NULL,
        MaxLat              DECIMAL(9,6)    NULL,
        MaxLong             DECIMAL(9,6)    NULL,
        AreaKm2             DECIMAL(12,3)   NULL,

        -- منشأ هندسه
        SourceFile          NVARCHAR(255)   NULL,               -- نام ZIP / اسکریپت
        SourceLayer         NVARCHAR(100)   NULL,               -- نام shp داخل ZIP
        SourceCrs           NVARCHAR(200)   NULL,               -- سیستم مختصات اصلی
        ImportBatch         UNIQUEIDENTIFIER NOT NULL,          -- بارگذاری‌ای که برگه را ساخت
        ImportedAt          DATETIME        NOT NULL CONSTRAINT DF_MapSheets_ImportedAt DEFAULT (GETDATE()),
        ImportedBy          NVARCHAR(100)   NULL,
        UpdatedAt           DATETIME        NULL,

        CONSTRAINT CK_MapSheets_SheetNo CHECK (LEN(LTRIM(RTRIM(SheetNo))) > 0)
    );
    CREATE UNIQUE INDEX UX_MapSheets_Scale_SheetNo ON dbo.MapSheets (SheetScale, SheetNo);
    CREATE INDEX IX_MapSheets_ImportBatch ON dbo.MapSheets (ImportBatch);
END
GO

------------------------------------------------------------------
-- 2) اتصال برگه به پروژه
------------------------------------------------------------------
IF OBJECT_ID(N'dbo.MapSheetProjects', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MapSheetProjects
    (
        ID                  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MapSheetProjects PRIMARY KEY,
        SheetID             INT             NOT NULL CONSTRAINT FK_MapSheetProjects_Sheet REFERENCES dbo.MapSheets (ID) ON DELETE CASCADE,
        ProjectCode         VARCHAR(20)     NOT NULL,           -- P_Code -> dbo.PWAInfo.ProjectCode (یکتا نیست: پروژهء چندنوعی چند سطر دارد)

        -- صفت‌های «پروژه روی برگه» به روایت فایل کارفرما
        ProjectName         NVARCHAR(200)   NULL,               -- P_Name
        Contractor          NVARCHAR(100)   NULL,               -- مجری
        Supervisor          NVARCHAR(100)   NULL,               -- ناظر
        Geologist           NVARCHAR(100)   NULL,               -- زمین‌شناس مسئول
        ExtraAttributes     NVARCHAR(MAX)   NULL,               -- JSON سایر ستون‌های dbf

        -- منشأ اتصال
        SourceFile          NVARCHAR(255)   NULL,
        SourceLayer         NVARCHAR(100)   NULL,
        ImportBatch         UNIQUEIDENTIFIER NOT NULL,
        ImportedAt          DATETIME        NOT NULL CONSTRAINT DF_MapSheetProjects_ImportedAt DEFAULT (GETDATE()),
        ImportedBy          NVARCHAR(100)   NULL,
        UpdatedAt           DATETIME        NULL,

        CONSTRAINT CK_MapSheetProjects_Code CHECK (LEN(LTRIM(RTRIM(ProjectCode))) > 0)
    );
    CREATE UNIQUE INDEX UX_MapSheetProjects_Sheet_Code ON dbo.MapSheetProjects (SheetID, ProjectCode);
    CREATE INDEX IX_MapSheetProjects_ProjectCode ON dbo.MapSheetProjects (ProjectCode);
    CREATE INDEX IX_MapSheetProjects_ImportBatch ON dbo.MapSheetProjects (ImportBatch);
END
GO

------------------------------------------------------------------
-- 3) انتقال دادهء نسخهء 1 (فقط یک بار؛ برگه‌هایی که از قبل منتقل شده‌اند رد می‌شوند)
------------------------------------------------------------------
IF OBJECT_ID(N'dbo.MapSheets_v1', N'U') IS NOT NULL
BEGIN
    INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
                               Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
                               SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedAt, ImportedBy, UpdatedAt)
    SELECT v.SheetNo, v.SheetScale, v.SheetSeries, v.SheetQuarter, v.SourceSheetID, v.SheetNameEn, v.SheetNameFa,
           v.Boundary, v.VertexCount, v.CentroidLat, v.CentroidLong, v.MinLat, v.MinLong, v.MaxLat, v.MaxLong, v.AreaKm2,
           v.SourceFile, v.SourceLayer, v.SourceCrs, v.ImportBatch, v.ImportedAt, v.ImportedBy, v.UpdatedAt
    FROM dbo.MapSheets_v1 v
    WHERE NOT EXISTS (SELECT 1 FROM dbo.MapSheets m WHERE m.SheetScale = v.SheetScale AND m.SheetNo = v.SheetNo);
    PRINT N'برگه‌های منتقل‌شده از نسخهء 1: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

    INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes,
                                      SourceFile, SourceLayer, ImportBatch, ImportedAt, ImportedBy, UpdatedAt)
    SELECT m.ID, v.ProjectCode, v.ProjectName, v.Contractor, v.Supervisor, v.Geologist, v.ExtraAttributes,
           v.SourceFile, v.SourceLayer, v.ImportBatch, v.ImportedAt, v.ImportedBy, v.UpdatedAt
    FROM dbo.MapSheets_v1 v
    JOIN dbo.MapSheets m ON m.SheetScale = v.SheetScale AND m.SheetNo = v.SheetNo
    WHERE v.ProjectCode IS NOT NULL AND LTRIM(RTRIM(v.ProjectCode)) <> ''
      AND NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects l WHERE l.SheetID = m.ID AND l.ProjectCode = v.ProjectCode);
    PRINT N'اتصال‌های منتقل‌شده از نسخهء 1: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
END
GO

------------------------------------------------------------------
-- 4) نما: یک سطر برای هر جفت برگه‌ـ‌پروژه + اولین سطر PWAInfo با همان کد
--    ستون‌های این نما = شناسه‌های فیلترهای جستجوی پیشرفته (Filter\js\demo_widgetsMapSheet.js) و ستون‌های وب‌متد FetchMapSheets
------------------------------------------------------------------
IF OBJECT_ID(N'dbo.vw_MapSheetsProjects', N'V') IS NOT NULL
    DROP VIEW dbo.vw_MapSheetsProjects;
GO

CREATE VIEW dbo.vw_MapSheetsProjects
AS
SELECT
    ms.ID, mp.ID AS LinkID,
    ms.SheetNo, ms.SheetScale, ms.SheetSeries, ms.SheetQuarter, ms.SourceSheetID, ms.SheetNameEn, ms.SheetNameFa,
    mp.ProjectCode, mp.ProjectName AS SheetProjectName, mp.Contractor, mp.Supervisor, mp.Geologist, mp.ExtraAttributes,
    ms.Boundary, ms.VertexCount, ms.CentroidLat, ms.CentroidLong, ms.MinLat, ms.MinLong, ms.MaxLat, ms.MaxLong, ms.AreaKm2,
    ms.SourceFile, ms.SourceLayer, ms.SourceCrs,
    mp.SourceFile AS LinkSourceFile, mp.ImportBatch, mp.ImportedAt, mp.ImportedBy, mp.UpdatedAt,
    pwa.PwaRowCount,
    p.ID AS PwaID, p.ProjectName, p.Status, p.PlannedProgress, p.ActualProgress, p.AchievementPct,
    p.StartDateJ, p.StartDate, p.FinishDateJ, p.FinishDate, p.PlannedStartJ, p.PlannedStart, p.PlannedFinishJ, p.PlannedFinish, p.TotalCost,
    p.ProjectType, p.Region, p.ExecutionMethod, p.ProjectManager, p.ProjectSupervisor, p.OrgLevel1, p.OrgLevel2,
    p.Lat AS PwaLat, p.[Long] AS PwaLong, p.TahaghoghCategory
FROM dbo.MapSheets ms
JOIN dbo.MapSheetProjects mp ON mp.SheetID = ms.ID
OUTER APPLY (SELECT COUNT(*) AS PwaRowCount FROM dbo.PWAInfo x WHERE x.ProjectCode = mp.ProjectCode) pwa
OUTER APPLY (SELECT TOP 1 * FROM dbo.PWAInfo y WHERE y.ProjectCode = mp.ProjectCode ORDER BY y.ID) p;
GO

------------------------------------------------------------------
-- 5) نمای کامل: یک سطر برای هر «اتصال × سطر PWAInfo» (LEFT JOIN تا اتصال بدون پروژه در PWA هم بماند)
--    فقط برای شرط جستجوی پیشرفته (EXISTS روی LinkID در ClsHelpper.FetchMapSheets)
------------------------------------------------------------------
IF OBJECT_ID(N'dbo.vw_MapSheetsProjectsAll', N'V') IS NOT NULL
    DROP VIEW dbo.vw_MapSheetsProjectsAll;
GO

CREATE VIEW dbo.vw_MapSheetsProjectsAll
AS
SELECT
    ms.ID, mp.ID AS LinkID,
    ms.SheetNo, ms.SheetScale, ms.SheetSeries, ms.SheetQuarter, ms.SourceSheetID, ms.SheetNameEn, ms.SheetNameFa,
    mp.ProjectCode, mp.ProjectName AS SheetProjectName, mp.Contractor, mp.Supervisor, mp.Geologist, mp.ExtraAttributes,
    ms.Boundary, ms.VertexCount, ms.CentroidLat, ms.CentroidLong, ms.MinLat, ms.MinLong, ms.MaxLat, ms.MaxLong, ms.AreaKm2,
    ms.SourceFile, ms.SourceLayer, ms.SourceCrs,
    mp.SourceFile AS LinkSourceFile, mp.ImportBatch, mp.ImportedAt, mp.ImportedBy, mp.UpdatedAt,
    pwa.PwaRowCount,
    p.ID AS PwaID, p.ProjectName, p.Status, p.PlannedProgress, p.ActualProgress, p.AchievementPct,
    p.StartDateJ, p.StartDate, p.FinishDateJ, p.FinishDate, p.PlannedStartJ, p.PlannedStart, p.PlannedFinishJ, p.PlannedFinish, p.TotalCost,
    p.ProjectType, p.Region, p.ExecutionMethod, p.ProjectManager, p.ProjectSupervisor, p.OrgLevel1, p.OrgLevel2,
    p.Lat AS PwaLat, p.[Long] AS PwaLong, p.TahaghoghCategory
FROM dbo.MapSheets ms
JOIN dbo.MapSheetProjects mp ON mp.SheetID = ms.ID
OUTER APPLY (SELECT COUNT(*) AS PwaRowCount FROM dbo.PWAInfo x WHERE x.ProjectCode = mp.ProjectCode) pwa
LEFT JOIN dbo.PWAInfo p ON p.ProjectCode = mp.ProjectCode;
GO

/* =====================================================================
   پرس‌وجوهای کنترلی
   ===================================================================== */

-- 1: اتصال‌هایی که کد پروژه‌شان در PWAInfo نیست (باید به کارفرما گزارش شود)
SELECT SheetNo, SheetNameFa, ProjectCode, LinkSourceFile
FROM dbo.vw_MapSheetsProjects
WHERE PwaRowCount = 0
ORDER BY SheetNo;

-- 2: برگه‌هایی که هیچ پروژه‌ای ندارند (در نقشه کشیده نمی‌شوند)
SELECT ms.SheetNo, ms.SheetNameFa, ms.SourceFile
FROM dbo.MapSheets ms
WHERE NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects l WHERE l.SheetID = ms.ID)
ORDER BY ms.SheetNo;

-- 3: برگه‌های چندپروژه‌ای
SELECT ms.SheetNo, ms.SheetNameFa, COUNT(*) AS Projects
FROM dbo.MapSheets ms JOIN dbo.MapSheetProjects l ON l.SheetID = ms.ID
GROUP BY ms.SheetNo, ms.SheetNameFa HAVING COUNT(*) > 1
ORDER BY Projects DESC;

-- 4: مقایسهء مختصات تقریبی PWAInfo با مرکز واقعی برگه (کیلومتر، تقریبی)
SELECT SheetNo, SheetNameFa, ProjectCode, Region, CentroidLat, CentroidLong, PwaLat, PwaLong,
       CAST(SQRT(SQUARE((CentroidLat - PwaLat) * 111.0) + SQUARE((CentroidLong - PwaLong) * 111.0 * COS(RADIANS(CentroidLat)))) AS DECIMAL(8,1)) AS DistKm
FROM dbo.vw_MapSheetsProjects
WHERE PwaLat IS NOT NULL
ORDER BY DistKm DESC;
GO

/* ------------------------------------------------------------------
   بعد از اطمینان از درستی مهاجرت، جدول نسخهء 1 را می‌توان حذف کرد:
   DROP TABLE dbo.MapSheets_v1;
   ------------------------------------------------------------------ */
