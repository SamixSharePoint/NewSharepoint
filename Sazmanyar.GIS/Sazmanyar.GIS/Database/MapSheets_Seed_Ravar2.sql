/*
    MapSheets_Seed_Ravar2 - داده‌های نمونه برای dbo.MapSheets
    ===================================================================
    منبع: Database\Ravar-map\Ravar2.* (Shapefile کارفرما، 11 برگهء 1:50000 طرح تحول راور)
    تولیدشده با همان خوانندهء C# وب‌پارت (Helper\ClsShapefile.cs) در 2026-09-20
    کاربرد: تست وب‌پارت ShowAllMapSheetInfo بدون بارگذاری ZIP. ابتدا MapSheets.sql اجرا شود.
    نکته: ردیف‌های چترود/حرجند در فایل کارفرما جابه‌جا هستند (هندسهء 7351-2 با نام «حرجند» و کد چترود)؛
          این اسکریپت عیناً فایل را ثبت می‌کند تا پس از پاسخ کارفرما اصلاح شود.
*/

SET NOCOUNT ON;
DECLARE @Batch UNIQUEIDENTIFIER = NEWID();

IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7351-2')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    ProjectCode, ProjectName, Contractor, Supervisor, Geologist, Boundary, VertexCount, CentroidLat, CentroidLong,
    MinLat, MinLong, MaxLat, MaxLong, AreaKm2, ExtraAttributes, SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7351-2', 50000, N'7351', N'2', 1833, N'Chatrud', N'حرجند',
    '140411094259', N'تهيه نقشه زمين شناسي 1:50000 حرجند 7451-3 (طرح تحول راور)', N'پژوهشکده علوم زمین', N'یوسف طباطبایی', N'مرتضی طالبیان',
    N'[{"lat":30.625000,"lng":57.000000},{"lat":30.500000,"lng":57.000000},{"lat":30.500000,"lng":56.875000},{"lat":30.500000,"lng":56.750000},{"lat":30.625000,"lng":56.750000},{"lat":30.750000,"lng":56.750000},{"lat":30.750000,"lng":56.875000},{"lat":30.750000,"lng":57.000000}]', 8, 30.625000, 56.875000,
    30.500000, 56.750000, 30.750000, 57.000000, 663.790, NULL, N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');

IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7451-3')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    ProjectCode, ProjectName, Contractor, Supervisor, Geologist, Boundary, VertexCount, CentroidLat, CentroidLong,
    MinLat, MinLong, MaxLat, MaxLong, AreaKm2, ExtraAttributes, SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7451-3', 50000, N'7451', N'3', 1834, N'Harjand', N'چترود',
    '140411094257', N'تهيه نقشه زمين شناسي 1:50000 چترود 7351-2 (طرح تحول راور)', N'دانشگاه فردوسی مشهد', N'یوسف طباطبایی', N'فرزین قائمی',
    N'[{"lat":30.625000,"lng":57.250000},{"lat":30.500000,"lng":57.250000},{"lat":30.500000,"lng":57.125000},{"lat":30.500000,"lng":57.000000},{"lat":30.625000,"lng":57.000000},{"lat":30.750000,"lng":57.000000},{"lat":30.750000,"lng":57.125000},{"lat":30.750000,"lng":57.250000}]', 8, 30.625000, 57.125000,
    30.500000, 57.000000, 30.750000, 57.250000, 663.790, NULL, N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');

IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7351-4')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    ProjectCode, ProjectName, Contractor, Supervisor, Geologist, Boundary, VertexCount, CentroidLat, CentroidLong,
    MinLat, MinLong, MaxLat, MaxLong, AreaKm2, ExtraAttributes, SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7351-4', 50000, N'7351', N'4', 1776, N'Zarand', N'زرند',
    '140411094258', N'تهيه نقشه زمين شناسي 1:50000 زرند 7351-4 (طرح تحول راور)', N'پژوهشکده علوم زمین', N'یوسف طباطبایی', N'حمید نظری',
    N'[{"lat":30.875000,"lng":56.750000},{"lat":30.750000,"lng":56.750000},{"lat":30.750000,"lng":56.625000},{"lat":30.750000,"lng":56.500000},{"lat":30.875000,"lng":56.500000},{"lat":31.000000,"lng":56.500000},{"lat":31.000000,"lng":56.625000},{"lat":31.000000,"lng":56.750000}]', 8, 30.875000, 56.625000,
    30.750000, 56.500000, 31.000000, 56.750000, 662.122, NULL, N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');

IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7351-1')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    ProjectCode, ProjectName, Contractor, Supervisor, Geologist, Boundary, VertexCount, CentroidLat, CentroidLong,
    MinLat, MinLong, MaxLat, MaxLong, AreaKm2, ExtraAttributes, SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7351-1', 50000, N'7351', N'1', 1777, N'Hotkadeh', N'هتکده',
    '140411094256', N'تهيه نقشه زمين شناسي 1:50000 هتكده 7351-1 (طرح تحول راور)', N'پژوهشکده علوم زمین', N'یوسف طباطبایی', N'حمید نظری',
    N'[{"lat":30.875000,"lng":57.000000},{"lat":30.750000,"lng":57.000000},{"lat":30.750000,"lng":56.875000},{"lat":30.750000,"lng":56.750000},{"lat":30.875000,"lng":56.750000},{"lat":31.000000,"lng":56.750000},{"lat":31.000000,"lng":56.875000},{"lat":31.000000,"lng":57.000000}]', 8, 30.875000, 56.875000,
    30.750000, 56.750000, 31.000000, 57.000000, 662.103, NULL, N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');

IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7451-4')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    ProjectCode, ProjectName, Contractor, Supervisor, Geologist, Boundary, VertexCount, CentroidLat, CentroidLong,
    MinLat, MinLong, MaxLat, MaxLong, AreaKm2, ExtraAttributes, SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7451-4', 50000, N'7451', N'4', 1778, N'Hodejk', N'هجدک',
    '140411094260', N'تهيه نقشه زمين شناسي 1:50000 هجدك 7451-4 (طرح تحول راور)', N'دانشگاه باهنر کرمان', N'یوسف طباطبایی', N'علی الهی',
    N'[{"lat":30.875000,"lng":57.250000},{"lat":30.750000,"lng":57.250000},{"lat":30.750000,"lng":57.125000},{"lat":30.750000,"lng":57.000000},{"lat":30.875000,"lng":57.000000},{"lat":31.000000,"lng":57.000000},{"lat":31.000000,"lng":57.125000},{"lat":31.000000,"lng":57.250000}]', 8, 30.875000, 57.125000,
    30.750000, 57.000000, 31.000000, 57.250000, 662.103, NULL, N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');

IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-3')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    ProjectCode, ProjectName, Contractor, Supervisor, Geologist, Boundary, VertexCount, CentroidLat, CentroidLong,
    MinLat, MinLong, MaxLat, MaxLong, AreaKm2, ExtraAttributes, SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7352-3', 50000, N'7352', N'3', 1718, N'Dasht khak', N'دشت خاک',
    '140411094254', N'تهيه نقشه زمين شناسي 1:50000 دشت خاك 7352-3 (طرح تحول راور)', N'دانشگاه باهنر کرمان', N'ناصر نعیمی قصابیان', N'حامد زند مقدم',
    N'[{"lat":31.125000,"lng":56.750000},{"lat":31.000000,"lng":56.750000},{"lat":31.000000,"lng":56.625000},{"lat":31.000000,"lng":56.500000},{"lat":31.125000,"lng":56.500000},{"lat":31.250000,"lng":56.500000},{"lat":31.250000,"lng":56.625000},{"lat":31.250000,"lng":56.750000}]', 8, 31.125000, 56.625000,
    31.000000, 56.500000, 31.250000, 56.750000, 660.422, NULL, N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');

IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-2')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    ProjectCode, ProjectName, Contractor, Supervisor, Geologist, Boundary, VertexCount, CentroidLat, CentroidLong,
    MinLat, MinLong, MaxLat, MaxLong, AreaKm2, ExtraAttributes, SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7352-2', 50000, N'7352', N'2', 1719, N'Sharif abad', N'شریف آباد',
    '140411094253', N'تهيه نقشه زمين شناسي 1:50000 شريف آباد 7352-2 (طرح تحول راور)', N'دانشگاه تهران', N'ناصر نعیمی قصابیان', N'علی کنعانیان',
    N'[{"lat":31.125000,"lng":57.000000},{"lat":31.000000,"lng":57.000000},{"lat":31.000000,"lng":56.875000},{"lat":31.000000,"lng":56.750000},{"lat":31.125000,"lng":56.750000},{"lat":31.250000,"lng":56.750000},{"lat":31.250000,"lng":56.875000},{"lat":31.250000,"lng":57.000000}]', 8, 31.125000, 56.875000,
    31.000000, 56.750000, 31.250000, 57.000000, 660.403, NULL, N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');

IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7452-3')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    ProjectCode, ProjectName, Contractor, Supervisor, Geologist, Boundary, VertexCount, CentroidLat, CentroidLong,
    MinLat, MinLong, MaxLat, MaxLong, AreaKm2, ExtraAttributes, SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7452-3', 50000, N'7452', N'3', 1720, N'Lakarkuh', N'لکرکوه',
    '140411094261', N'تهيه نقشه زمين شناسي 1:50000 لكركوه 7452-1 (طرح تحول راور)', N'دانشگاه تهران', N'ناصر نعیمی قصابیان', N'شجاع الدین نیرومند',
    N'[{"lat":31.125000,"lng":57.250000},{"lat":31.000000,"lng":57.250000},{"lat":31.000000,"lng":57.125000},{"lat":31.000000,"lng":57.000000},{"lat":31.125000,"lng":57.000000},{"lat":31.250000,"lng":57.000000},{"lat":31.250000,"lng":57.125000},{"lat":31.250000,"lng":57.250000}]', 8, 31.125000, 57.125000,
    31.000000, 57.000000, 31.250000, 57.250000, 660.403, NULL, N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');

IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-4')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    ProjectCode, ProjectName, Contractor, Supervisor, Geologist, Boundary, VertexCount, CentroidLat, CentroidLong,
    MinLat, MinLong, MaxLat, MaxLong, AreaKm2, ExtraAttributes, SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7352-4', 50000, N'7352', N'4', 1660, N'Kahnouj', N'کهنوج',
    '140411094255', N'تهيه نقشه زمين شناسي 1:50000 كهنوج 7352-4 (طرح تحول راور)', N'دانشگاه باهنر کرمان', N'ناصر نعیمی قصابیان', N'شهرام شفیعی بافتی',
    N'[{"lat":31.375000,"lng":56.750000},{"lat":31.250000,"lng":56.750000},{"lat":31.250000,"lng":56.625000},{"lat":31.250000,"lng":56.500000},{"lat":31.375000,"lng":56.500000},{"lat":31.500000,"lng":56.500000},{"lat":31.500000,"lng":56.625000},{"lat":31.500000,"lng":56.750000}]', 8, 31.375000, 56.625000,
    31.250000, 56.500000, 31.500000, 56.750000, 658.710, NULL, N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');

IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7352-1')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    ProjectCode, ProjectName, Contractor, Supervisor, Geologist, Boundary, VertexCount, CentroidLat, CentroidLong,
    MinLat, MinLong, MaxLat, MaxLong, AreaKm2, ExtraAttributes, SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7352-1', 50000, N'7352', N'1', 1661, N'Ravar', N'راور',
    '140411094252', N'تهيه نقشه زمين شناسي 1:50000 راور 7352-1 (طرح تحول راور)', N'دانشگاه تهران', N'ناصر نعیمی قصابیان', N'علی کنعانیان',
    N'[{"lat":31.375000,"lng":57.000000},{"lat":31.250000,"lng":57.000000},{"lat":31.250000,"lng":56.875000},{"lat":31.250000,"lng":56.750000},{"lat":31.375000,"lng":56.750000},{"lat":31.500000,"lng":56.750000},{"lat":31.500000,"lng":56.875000},{"lat":31.500000,"lng":57.000000}]', 8, 31.375000, 56.875000,
    31.250000, 56.750000, 31.500000, 57.000000, 658.691, NULL, N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');

IF NOT EXISTS (SELECT 1 FROM dbo.MapSheets WHERE SheetScale = 50000 AND SheetNo = N'7452-4')
INSERT INTO dbo.MapSheets (SheetNo, SheetScale, SheetSeries, SheetQuarter, SourceSheetID, SheetNameEn, SheetNameFa,
    ProjectCode, ProjectName, Contractor, Supervisor, Geologist, Boundary, VertexCount, CentroidLat, CentroidLong,
    MinLat, MinLong, MaxLat, MaxLong, AreaKm2, ExtraAttributes, SourceFile, SourceLayer, SourceCrs, ImportBatch, ImportedBy)
VALUES (N'7452-4', 50000, N'7452', N'4', 1662, N'Rudkhnaeh suzva', N'رودخانه سوزو',
    '140411094262', N'تهيه نقشه زمين شناسي 1:50000 رودخانه سوزو 7452-2 (طرح تحول راو', N'دانشگاه تهران', N'ناصر نعیمی قصابیان', N'شجاع الدین نیرومند',
    N'[{"lat":31.375000,"lng":57.250000},{"lat":31.250000,"lng":57.250000},{"lat":31.250000,"lng":57.125000},{"lat":31.250000,"lng":57.000000},{"lat":31.375000,"lng":57.000000},{"lat":31.500000,"lng":57.000000},{"lat":31.500000,"lng":57.125000},{"lat":31.500000,"lng":57.250000}]', 8, 31.375000, 57.125000,
    31.250000, 57.000000, 31.500000, 57.250000, 658.691, NULL, N'Ravar-map.zip', N'Ravar2', N'WGS_1984_UTM_Zone_40N', @Batch, N'seed script');

SELECT SheetNo, SheetNameFa, ProjectCode, CentroidLat, CentroidLong, AreaKm2 FROM dbo.MapSheets WHERE ImportBatch = @Batch ORDER BY SheetNo;
GO
