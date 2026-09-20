/*
    MapSheets_Seed_Ravar2 - داده‌های نمونه برای dbo.MapSheets + dbo.MapSheetProjects
    ===================================================================
    منبع: Database\Ravar-map\Ravar2.* (Shapefile کارفرما، 11 برگهء 1:50000 طرح تحول راور)
    تولیدشده با همان خوانندهء C# وب‌پارت (Helper\ClsShapefile.cs) در 2026-09-20
    کاربرد: تست وب‌پارت ShowAllMapSheetInfo بدون بارگذاری ZIP. ابتدا MapSheets.sql (نسخهء 2) اجرا شود.
    هر برگه: اگر نباشد ثبت می‌شود؛ سپس اتصال پروژه (اگر نباشد) در جدول واسط. اجرای مجدد بی‌خطر است.
    نکته: ردیف‌های چترود/حرجند در فایل کارفرما جابه‌جا هستند (هندسهء 7351-2 با نام «حرجند» و کد چترود)؛
          این اسکریپت عیناً فایل را ثبت می‌کند تا پس از پاسخ کارفرما اصلاح شود.
*/

SET NOCOUNT ON;
DECLARE @Batch UNIQUEIDENTIFIER = NEWID();
DECLARE @SheetID INT;

-- 7351-2 حرجند / 140411094259
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7351-2')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
    SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7351-2', 50000, N'7351', N'2', 1833, N'Chatrud', N'حرجند',
    N'[{"lat":30.625000,"lng":57.000000},{"lat":30.500000,"lng":57.000000},{"lat":30.500000,"lng":56.875000},{"lat":30.500000,"lng":56.750000},{"lat":30.625000,"lng":56.750000},{"lat":30.750000,"lng":56.750000},{"lat":30.750000,"lng":56.875000},{"lat":30.750000,"lng":57.000000}]', 8, 30.625000, 56.875000,
    30.500000, 56.750000, 30.750000, 57.000000, 663.790,
    N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');
SELECT @SheetID = ID FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7351-2';
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = '140411094259')
INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, SourceFile, SourceLayer, ImportBatch, ImportedBy)
VALUES (@SheetID, '140411094259', N'تهيه نقشه زمين شناسي 1:50000 حرجند 7451-3 (طرح تحول راور)', N'پژوهشکده علوم زمین', N'یوسف طباطبایی', N'مرتضی طالبیان', NULL, N'Ravar-map.zip', N'Ravar2', @Batch, N'seed script');

-- 7451-3 چترود / 140411094257
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7451-3')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
    SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7451-3', 50000, N'7451', N'3', 1834, N'Harjand', N'چترود',
    N'[{"lat":30.625000,"lng":57.250000},{"lat":30.500000,"lng":57.250000},{"lat":30.500000,"lng":57.125000},{"lat":30.500000,"lng":57.000000},{"lat":30.625000,"lng":57.000000},{"lat":30.750000,"lng":57.000000},{"lat":30.750000,"lng":57.125000},{"lat":30.750000,"lng":57.250000}]', 8, 30.625000, 57.125000,
    30.500000, 57.000000, 30.750000, 57.250000, 663.790,
    N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');
SELECT @SheetID = ID FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7451-3';
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = '140411094257')
INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, SourceFile, SourceLayer, ImportBatch, ImportedBy)
VALUES (@SheetID, '140411094257', N'تهيه نقشه زمين شناسي 1:50000 چترود 7351-2 (طرح تحول راور)', N'دانشگاه فردوسی مشهد', N'یوسف طباطبایی', N'فرزین قائمی', NULL, N'Ravar-map.zip', N'Ravar2', @Batch, N'seed script');

-- 7351-4 زرند / 140411094258
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7351-4')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
    SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7351-4', 50000, N'7351', N'4', 1776, N'Zarand', N'زرند',
    N'[{"lat":30.875000,"lng":56.750000},{"lat":30.750000,"lng":56.750000},{"lat":30.750000,"lng":56.625000},{"lat":30.750000,"lng":56.500000},{"lat":30.875000,"lng":56.500000},{"lat":31.000000,"lng":56.500000},{"lat":31.000000,"lng":56.625000},{"lat":31.000000,"lng":56.750000}]', 8, 30.875000, 56.625000,
    30.750000, 56.500000, 31.000000, 56.750000, 662.122,
    N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');
SELECT @SheetID = ID FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7351-4';
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = '140411094258')
INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, SourceFile, SourceLayer, ImportBatch, ImportedBy)
VALUES (@SheetID, '140411094258', N'تهيه نقشه زمين شناسي 1:50000 زرند 7351-4 (طرح تحول راور)', N'پژوهشکده علوم زمین', N'یوسف طباطبایی', N'حمید نظری', NULL, N'Ravar-map.zip', N'Ravar2', @Batch, N'seed script');

-- 7351-1 هتکده / 140411094256
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7351-1')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
    SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7351-1', 50000, N'7351', N'1', 1777, N'Hotkadeh', N'هتکده',
    N'[{"lat":30.875000,"lng":57.000000},{"lat":30.750000,"lng":57.000000},{"lat":30.750000,"lng":56.875000},{"lat":30.750000,"lng":56.750000},{"lat":30.875000,"lng":56.750000},{"lat":31.000000,"lng":56.750000},{"lat":31.000000,"lng":56.875000},{"lat":31.000000,"lng":57.000000}]', 8, 30.875000, 56.875000,
    30.750000, 56.750000, 31.000000, 57.000000, 662.103,
    N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');
SELECT @SheetID = ID FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7351-1';
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = '140411094256')
INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, SourceFile, SourceLayer, ImportBatch, ImportedBy)
VALUES (@SheetID, '140411094256', N'تهيه نقشه زمين شناسي 1:50000 هتكده 7351-1 (طرح تحول راور)', N'پژوهشکده علوم زمین', N'یوسف طباطبایی', N'حمید نظری', NULL, N'Ravar-map.zip', N'Ravar2', @Batch, N'seed script');

-- 7451-4 هجدک / 140411094260
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7451-4')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
    SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7451-4', 50000, N'7451', N'4', 1778, N'Hodejk', N'هجدک',
    N'[{"lat":30.875000,"lng":57.250000},{"lat":30.750000,"lng":57.250000},{"lat":30.750000,"lng":57.125000},{"lat":30.750000,"lng":57.000000},{"lat":30.875000,"lng":57.000000},{"lat":31.000000,"lng":57.000000},{"lat":31.000000,"lng":57.125000},{"lat":31.000000,"lng":57.250000}]', 8, 30.875000, 57.125000,
    30.750000, 57.000000, 31.000000, 57.250000, 662.103,
    N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');
SELECT @SheetID = ID FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7451-4';
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = '140411094260')
INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, SourceFile, SourceLayer, ImportBatch, ImportedBy)
VALUES (@SheetID, '140411094260', N'تهيه نقشه زمين شناسي 1:50000 هجدك 7451-4 (طرح تحول راور)', N'دانشگاه باهنر کرمان', N'یوسف طباطبایی', N'علی الهی', NULL, N'Ravar-map.zip', N'Ravar2', @Batch, N'seed script');

-- 7352-3 دشت خاک / 140411094254
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-3')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
    SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7352-3', 50000, N'7352', N'3', 1718, N'Dasht khak', N'دشت خاک',
    N'[{"lat":31.125000,"lng":56.750000},{"lat":31.000000,"lng":56.750000},{"lat":31.000000,"lng":56.625000},{"lat":31.000000,"lng":56.500000},{"lat":31.125000,"lng":56.500000},{"lat":31.250000,"lng":56.500000},{"lat":31.250000,"lng":56.625000},{"lat":31.250000,"lng":56.750000}]', 8, 31.125000, 56.625000,
    31.000000, 56.500000, 31.250000, 56.750000, 660.422,
    N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');
SELECT @SheetID = ID FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-3';
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = '140411094254')
INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, SourceFile, SourceLayer, ImportBatch, ImportedBy)
VALUES (@SheetID, '140411094254', N'تهيه نقشه زمين شناسي 1:50000 دشت خاك 7352-3 (طرح تحول راور)', N'دانشگاه باهنر کرمان', N'ناصر نعیمی قصابیان', N'حامد زند مقدم', NULL, N'Ravar-map.zip', N'Ravar2', @Batch, N'seed script');

-- 7352-2 شریف آباد / 140411094253
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-2')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
    SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7352-2', 50000, N'7352', N'2', 1719, N'Sharif abad', N'شریف آباد',
    N'[{"lat":31.125000,"lng":57.000000},{"lat":31.000000,"lng":57.000000},{"lat":31.000000,"lng":56.875000},{"lat":31.000000,"lng":56.750000},{"lat":31.125000,"lng":56.750000},{"lat":31.250000,"lng":56.750000},{"lat":31.250000,"lng":56.875000},{"lat":31.250000,"lng":57.000000}]', 8, 31.125000, 56.875000,
    31.000000, 56.750000, 31.250000, 57.000000, 660.403,
    N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');
SELECT @SheetID = ID FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-2';
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = '140411094253')
INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, SourceFile, SourceLayer, ImportBatch, ImportedBy)
VALUES (@SheetID, '140411094253', N'تهيه نقشه زمين شناسي 1:50000 شريف آباد 7352-2 (طرح تحول راور)', N'دانشگاه تهران', N'ناصر نعیمی قصابیان', N'علی کنعانیان', NULL, N'Ravar-map.zip', N'Ravar2', @Batch, N'seed script');

-- 7452-3 لکرکوه / 140411094261
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7452-3')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
    SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7452-3', 50000, N'7452', N'3', 1720, N'Lakarkuh', N'لکرکوه',
    N'[{"lat":31.125000,"lng":57.250000},{"lat":31.000000,"lng":57.250000},{"lat":31.000000,"lng":57.125000},{"lat":31.000000,"lng":57.000000},{"lat":31.125000,"lng":57.000000},{"lat":31.250000,"lng":57.000000},{"lat":31.250000,"lng":57.125000},{"lat":31.250000,"lng":57.250000}]', 8, 31.125000, 57.125000,
    31.000000, 57.000000, 31.250000, 57.250000, 660.403,
    N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');
SELECT @SheetID = ID FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7452-3';
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = '140411094261')
INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, SourceFile, SourceLayer, ImportBatch, ImportedBy)
VALUES (@SheetID, '140411094261', N'تهيه نقشه زمين شناسي 1:50000 لكركوه 7452-1 (طرح تحول راور)', N'دانشگاه تهران', N'ناصر نعیمی قصابیان', N'شجاع الدین نیرومند', NULL, N'Ravar-map.zip', N'Ravar2', @Batch, N'seed script');

-- 7352-4 کهنوج / 140411094255
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-4')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
    SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7352-4', 50000, N'7352', N'4', 1660, N'Kahnouj', N'کهنوج',
    N'[{"lat":31.375000,"lng":56.750000},{"lat":31.250000,"lng":56.750000},{"lat":31.250000,"lng":56.625000},{"lat":31.250000,"lng":56.500000},{"lat":31.375000,"lng":56.500000},{"lat":31.500000,"lng":56.500000},{"lat":31.500000,"lng":56.625000},{"lat":31.500000,"lng":56.750000}]', 8, 31.375000, 56.625000,
    31.250000, 56.500000, 31.500000, 56.750000, 658.710,
    N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');
SELECT @SheetID = ID FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-4';
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = '140411094255')
INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, SourceFile, SourceLayer, ImportBatch, ImportedBy)
VALUES (@SheetID, '140411094255', N'تهيه نقشه زمين شناسي 1:50000 كهنوج 7352-4 (طرح تحول راور)', N'دانشگاه باهنر کرمان', N'ناصر نعیمی قصابیان', N'شهرام شفیعی بافتی', NULL, N'Ravar-map.zip', N'Ravar2', @Batch, N'seed script');

-- 7352-1 راور / 140411094252
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-1')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
    SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7352-1', 50000, N'7352', N'1', 1661, N'Ravar', N'راور',
    N'[{"lat":31.375000,"lng":57.000000},{"lat":31.250000,"lng":57.000000},{"lat":31.250000,"lng":56.875000},{"lat":31.250000,"lng":56.750000},{"lat":31.375000,"lng":56.750000},{"lat":31.500000,"lng":56.750000},{"lat":31.500000,"lng":56.875000},{"lat":31.500000,"lng":57.000000}]', 8, 31.375000, 56.875000,
    31.250000, 56.750000, 31.500000, 57.000000, 658.691,
    N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');
SELECT @SheetID = ID FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-1';
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = '140411094252')
INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, SourceFile, SourceLayer, ImportBatch, ImportedBy)
VALUES (@SheetID, '140411094252', N'تهيه نقشه زمين شناسي 1:50000 راور 7352-1 (طرح تحول راور)', N'دانشگاه تهران', N'ناصر نعیمی قصابیان', N'علی کنعانیان', NULL, N'Ravar-map.zip', N'Ravar2', @Batch, N'seed script');

-- 7452-4 رودخانه سوزو / 140411094262
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7452-4')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    Boundary, VertexCount, CentroidLat, CentroidLong, MinLat, MinLong, MaxLat, MaxLong, AreaKm2,
    SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7452-4', 50000, N'7452', N'4', 1662, N'Rudkhnaeh suzva', N'رودخانه سوزو',
    N'[{"lat":31.375000,"lng":57.250000},{"lat":31.250000,"lng":57.250000},{"lat":31.250000,"lng":57.125000},{"lat":31.250000,"lng":57.000000},{"lat":31.375000,"lng":57.000000},{"lat":31.500000,"lng":57.000000},{"lat":31.500000,"lng":57.125000},{"lat":31.500000,"lng":57.250000}]', 8, 31.375000, 57.125000,
    31.250000, 57.000000, 31.500000, 57.250000, 658.691,
    N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');
SELECT @SheetID = ID FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7452-4';
IF NOT EXISTS (SELECT 1 FROM dbo.MapSheetProjects WHERE SheetID = @SheetID AND ProjectCode = '140411094262')
INSERT INTO dbo.MapSheetProjects (SheetID, ProjectCode, ProjectName, Contractor, Supervisor, Geologist, ExtraAttributes, SourceFile, SourceLayer, ImportBatch, ImportedBy)
VALUES (@SheetID, '140411094262', N'تهيه نقشه زمين شناسي 1:50000 رودخانه سوزو 7452-2 (طرح تحول راو', N'دانشگاه تهران', N'ناصر نعیمی قصابیان', N'شجاع الدین نیرومند', NULL, N'Ravar-map.zip', N'Ravar2', @Batch, N'seed script');

SELECT SheetNo, SheetNameFa, ProjectCode, CentroidLat, CentroidLong, AreaKm2 FROM dbo.vw_MapSheetsProjects WHERE SourceFile = N'Ravar-map.zip' ORDER BY SheetNo;
GO
