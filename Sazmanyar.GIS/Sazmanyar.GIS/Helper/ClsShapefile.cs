using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;

namespace Sazmanyar.GIS.Helper
{
    /// <summary>یک رأس چندضلعی به درجهء اعشاری WGS84</summary>
    public class GeoPoint
    {
        public double lat { get; set; }
        public double lng { get; set; }
        public GeoPoint() { }
        public GeoPoint(double dLat, double dLng) { lat = dLat; lng = dLng; }
    }

    /// <summary>یک سطر خوانده‌شده از Shapefile که آمادهء ثبت در dbo.MapSheets است</summary>
    public class MapSheetRecord
    {
        public int RowIndex { get; set; }                   // شمارهء رکورد در فایل (از 1)
        public string SheetNo { get; set; }
        public int SheetScale { get; set; }
        public string SheetSeries { get; set; }
        public string SheetQuarter { get; set; }
        public long? SourceSheetID { get; set; }
        public string SheetNameEn { get; set; }
        public string SheetNameFa { get; set; }
        public string ProjectCode { get; set; }
        public string ProjectName { get; set; }
        public string Contractor { get; set; }
        public string Supervisor { get; set; }
        public string Geologist { get; set; }
        public List<GeoPoint> Boundary { get; set; }
        public double CentroidLat { get; set; }
        public double CentroidLong { get; set; }
        public double MinLat { get; set; }
        public double MinLong { get; set; }
        public double MaxLat { get; set; }
        public double MaxLong { get; set; }
        public double AreaKm2 { get; set; }
        public Dictionary<string, string> ExtraAttributes { get; set; }
        public string SourceLayer { get; set; }
        public string SourceCrs { get; set; }
        public List<string> Warnings { get; set; }

        public MapSheetRecord()
        {
            SheetScale = 50000;
            Boundary = new List<GeoPoint>();
            ExtraAttributes = new Dictionary<string, string>();
            Warnings = new List<string>();
        }

        /// <summary>JSON حلقهء بیرونی با همان قالب PolygonPoints لیست سطح‌ها: [{"lat":..,"lng":..},...]</summary>
        public string BoundaryJson
        {
            get
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("[");
                for (int i = 0; i < Boundary.Count; i++)
                {
                    if (i > 0) { sb.Append(","); }
                    sb.Append("{\"lat\":").Append(Boundary[i].lat.ToString("0.000000", CultureInfo.InvariantCulture))
                      .Append(",\"lng\":").Append(Boundary[i].lng.ToString("0.000000", CultureInfo.InvariantCulture)).Append("}");
                }
                sb.Append("]");
                return sb.ToString();
            }
        }

        public string ExtraAttributesJson
        {
            get
            {
                if (ExtraAttributes == null || ExtraAttributes.Count == 0) { return null; }
                return new JavaScriptSerializer().Serialize(ExtraAttributes);
            }
        }

        /// <summary>عنوان کوتاه برای پیام‌ها</summary>
        public string Label
        {
            get
            {
                string s = string.IsNullOrEmpty(SheetNo) ? ("رکورد " + RowIndex) : SheetNo;
                if (!string.IsNullOrEmpty(SheetNameFa)) { s += " (" + SheetNameFa + ")"; }
                return s;
            }
        }
    }

    /// <summary>نتیجهء خواندن یک ZIP</summary>
    public class ShapefileParseResult
    {
        public List<MapSheetRecord> Records { get; set; }
        public List<string> Messages { get; set; }          // اطلاع‌رسانی (لایه، سیستم مختصات، ستون‌ها)
        public List<string> Errors { get; set; }            // خطاهایی که کل فایل یا یک رکورد را رد کرده‌اند
        public bool HasFatalError { get; set; }

        public ShapefileParseResult()
        {
            Records = new List<MapSheetRecord>();
            Messages = new List<string>();
            Errors = new List<string>();
        }
    }

    /// <summary>
    /// خوانندهء Shapefile (ESRI) از داخل ZIP، بدون وابستگی به کتابخانهء خارجی.
    /// پشتیبانی: هندسهء Polygon / PolygonZ / PolygonM، جدول dbf (کدپیج از cpg)، سیستم مختصات از prj:
    ///   * GEOGCS (درجهء اعشاری) بدون تبدیل
    ///   * PROJCS با Transverse_Mercator (مثل UTM Zone 40N) با فرمول معکوس روی همان بیضوی prj
    /// خروجی مستقل از پایگاه داده است؛ ثبت در جدول در ClsHelpper.ImportMapSheets انجام می‌شود.
    /// </summary>
    public static class ClsShapefile
    {
        #region نگاشت نام ستون‌های dbf

        // نام ستون‌های dbf بعد از نرمال‌سازی (حروف بزرگ، ي/ك عربی -> ی/ک، حذف نیم‌فاصله، فاصله -> _)
        private static readonly string[] COL_SHEETNO = { "N50", "N100", "N25", "N250", "SHEETNO", "SHEET_NO", "SHEET", "SHEETNUMBER", "برگه", "شماره_برگه", "شمارهبرگه" };
        private static readonly string[] COL_SERIES = { "NO50", "NO100", "NO25", "SERIES", "SHEETSERIES", "SHEET_SERIES" };
        private static readonly string[] COL_QUARTER = { "N1_4", "QUARTER", "SHEETQUARTER", "ربع" };
        private static readonly string[] COL_SOURCEID = { "ID", "OBJECTID", "FID", "SHEETID", "SHEET_ID" };
        private static readonly string[] COL_NAME_EN = { "EN_NAME_50", "EN_NAME_100", "EN_NAME", "NAME_EN", "ENGLISH", "ENNAME", "NAMEEN" };
        private static readonly string[] COL_NAME_FA = { "NAME_FARSI", "P_NAME_50", "P_NAME_100", "FA_NAME", "NAME_FA", "FANAME", "NAMEFA", "نام", "نام_فارسی", "نام_برگه" };
        private static readonly string[] COL_PCODE = { "P_CODE", "PCODE", "PROJECTCODE", "PROJECT_CODE", "PROJ_CODE", "کد_پروژه", "کدپروژه", "کد" };
        private static readonly string[] COL_PNAME = { "P_NAME", "PNAME", "PROJECTNAME", "PROJECT_NAME", "PROJ_NAME", "نام_پروژه", "نامپروژه" };
        private static readonly string[] COL_CONTRACTOR = { "مجری", "CONTRACTOR", "MOJRI", "EXECUTOR" };
        private static readonly string[] COL_SUPERVISOR = { "ناظر", "SUPERVISOR", "NAZER" };
        private static readonly string[] COL_GEOLOGIST = { "زمین", "زمینشناس", "زمین_شناس", "GEOLOGIST", "GEO" };

        private static string NormalizeName(string s)
        {
            if (s == null) { return ""; }
            s = s.Replace('ي', 'ی').Replace('ك', 'ک')   // ي -> ی ، ك -> ک
                 .Replace("‌", "").Replace("‏", "").Replace("‎", "")
                 .Trim().Replace(' ', '_').Replace('-', '_');
            return s.ToUpperInvariant();
        }

        private static int FindColumn(string[] fieldNames, string[] aliases)
        {
            for (int a = 0; a < aliases.Length; a++)
            {
                string want = NormalizeName(aliases[a]);
                for (int i = 0; i < fieldNames.Length; i++)
                {
                    if (NormalizeName(fieldNames[i]) == want) { return i; }
                }
            }
            return -1;
        }

        /// <summary>مقیاس از روی نام ستون شمارهء برگه (N50 = 1:50000 ...)</summary>
        private static int ScaleFromColumnName(string colName)
        {
            Match m = Regex.Match(NormalizeName(colName), @"^N(\d+)$");
            if (m.Success)
            {
                int k = Convert.ToInt32(m.Groups[1].Value);
                if (k == 25 || k == 50 || k == 100 || k == 250) { return k * 1000; }
            }
            return 50000;
        }

        #endregion

        #region ورودی ZIP

        private class ShapeSet
        {
            public string Name;
            public byte[] Shp;
            public byte[] Dbf;
            public byte[] Prj;
            public byte[] Cpg;
        }

        /// <summary>ZIP را می‌خواند و همهء لایه‌های shp داخل آن را به رکوردهای برگه تبدیل می‌کند.</summary>
        public static ShapefileParseResult ParseZip(Stream zipStream)
        {
            ShapefileParseResult result = new ShapefileParseResult();
            Dictionary<string, ShapeSet> sets = new Dictionary<string, ShapeSet>(StringComparer.OrdinalIgnoreCase);

            try
            {
                using (ZipArchive zip = new ZipArchive(zipStream, ZipArchiveMode.Read, true))
                {
                    foreach (ZipArchiveEntry entry in zip.Entries)
                    {
                        if (string.IsNullOrEmpty(entry.Name)) { continue; }   // پوشه
                        string ext = Path.GetExtension(entry.Name).ToLowerInvariant();
                        if (ext != ".shp" && ext != ".dbf" && ext != ".prj" && ext != ".cpg") { continue; }
                        string baseName = Path.GetFileNameWithoutExtension(entry.Name);
                        ShapeSet set;
                        if (!sets.TryGetValue(baseName, out set))
                        {
                            set = new ShapeSet();
                            set.Name = baseName;
                            sets[baseName] = set;
                        }
                        byte[] data = ReadEntry(entry);
                        if (ext == ".shp") { set.Shp = data; }
                        else if (ext == ".dbf") { set.Dbf = data; }
                        else if (ext == ".prj") { set.Prj = data; }
                        else { set.Cpg = data; }
                    }
                }
            }
            catch (Exception ex)
            {
                result.Errors.Add("فایل ZIP قابل خواندن نیست: " + ex.Message);
                result.HasFatalError = true;
                return result;
            }

            int layers = 0;
            foreach (ShapeSet set in sets.Values)
            {
                if (set.Shp == null) { continue; }
                layers++;
                if (set.Dbf == null)
                {
                    result.Errors.Add("لایهء " + set.Name + ": فایل dbf (جدول صفت‌ها) در ZIP نیست؛ رد شد.");
                    continue;
                }
                ParseLayer(set, result);
            }

            if (layers == 0)
            {
                result.Errors.Add("هیچ فایل shp داخل ZIP پیدا نشد.");
                result.HasFatalError = true;
            }
            return result;
        }

        private static byte[] ReadEntry(ZipArchiveEntry entry)
        {
            using (Stream s = entry.Open())
            using (MemoryStream ms = new MemoryStream())
            {
                s.CopyTo(ms);
                return ms.ToArray();
            }
        }

        #endregion

        #region یک لایه

        private static void ParseLayer(ShapeSet set, ShapefileParseResult result)
        {
            // --- سیستم مختصات ---
            CrsInfo crs = ParseCrs(set.Prj);
            string crsLabel = crs.Name;
            if (!crs.Supported)
            {
                result.Errors.Add("لایهء " + set.Name + ": سیستم مختصات پشتیبانی نمی‌شود (" + crsLabel + "). فقط درجهء اعشاری (GEOGCS) یا Transverse Mercator/UTM قابل خواندن است.");
                return;
            }
            if (crs.Warning != null) { result.Messages.Add("لایهء " + set.Name + ": " + crs.Warning); }

            // --- جدول صفت‌ها ---
            DbfTable dbf;
            try
            {
                dbf = ReadDbf(set.Dbf, set.Cpg);
            }
            catch (Exception ex)
            {
                result.Errors.Add("لایهء " + set.Name + ": خواندن dbf ناموفق بود: " + ex.Message);
                return;
            }

            // --- هندسه ---
            List<ShapeGeometry> shapes;
            try
            {
                shapes = ReadShp(set.Shp);
            }
            catch (Exception ex)
            {
                result.Errors.Add("لایهء " + set.Name + ": خواندن shp ناموفق بود: " + ex.Message);
                return;
            }

            result.Messages.Add("لایهء " + set.Name + ": " + shapes.Count + " رکورد هندسه، " + dbf.Rows.Count + " سطر صفت، سیستم مختصات: " + crsLabel
                + "، کدپیج: " + dbf.EncodingName + "، ستون‌ها: " + string.Join("، ", dbf.FieldNames));

            if (shapes.Count != dbf.Rows.Count)
            {
                result.Messages.Add("لایهء " + set.Name + ": تعداد رکوردهای shp و dbf برابر نیست (" + shapes.Count + " / " + dbf.Rows.Count + ")؛ فقط رکوردهای مشترک خوانده می‌شوند.");
            }

            // --- نگاشت ستون‌ها ---
            int cSheet = FindColumn(dbf.FieldNames, COL_SHEETNO);
            int cSeries = FindColumn(dbf.FieldNames, COL_SERIES);
            int cQuarter = FindColumn(dbf.FieldNames, COL_QUARTER);
            int cSrcId = FindColumn(dbf.FieldNames, COL_SOURCEID);
            int cNameEn = FindColumn(dbf.FieldNames, COL_NAME_EN);
            int cNameFa = FindColumn(dbf.FieldNames, COL_NAME_FA);
            int cPCode = FindColumn(dbf.FieldNames, COL_PCODE);
            int cPName = FindColumn(dbf.FieldNames, COL_PNAME);
            int cContractor = FindColumn(dbf.FieldNames, COL_CONTRACTOR);
            int cSupervisor = FindColumn(dbf.FieldNames, COL_SUPERVISOR);
            int cGeologist = FindColumn(dbf.FieldNames, COL_GEOLOGIST);
            int scale = cSheet >= 0 ? ScaleFromColumnName(dbf.FieldNames[cSheet]) : 50000;

            if (cSheet < 0)
            {
                result.Messages.Add("لایهء " + set.Name + ": ستون شمارهء برگه (N50) پیدا نشد؛ شمارهء برگه از ستون شناسه یا شمارهء رکورد ساخته می‌شود.");
            }
            if (cPCode < 0)
            {
                result.Messages.Add("لایهء " + set.Name + ": ستون کد پروژه (P_Code) پیدا نشد؛ برگه‌ها بدون اتصال به PWAInfo ثبت می‌شوند.");
            }

            List<int> mapped = new List<int>(new[] { cSheet, cSeries, cQuarter, cSrcId, cNameEn, cNameFa, cPCode, cPName, cContractor, cSupervisor, cGeologist });

            int n = Math.Min(shapes.Count, dbf.Rows.Count);
            for (int i = 0; i < n; i++)
            {
                MapSheetRecord rec = new MapSheetRecord();
                rec.RowIndex = i + 1;
                rec.SourceLayer = set.Name;
                rec.SourceCrs = crsLabel;
                rec.SheetScale = scale;
                string[] row = dbf.Rows[i];

                rec.SheetNo = Clean(Get(row, cSheet));
                rec.SheetSeries = Clean(Get(row, cSeries));
                rec.SheetQuarter = Clean(Get(row, cQuarter));
                rec.SheetNameEn = Clean(Get(row, cNameEn));
                rec.SheetNameFa = Clean(Get(row, cNameFa));
                rec.ProjectCode = NormalizeProjectCode(Get(row, cPCode));
                rec.ProjectName = Clean(Get(row, cPName));
                rec.Contractor = Clean(Get(row, cContractor));
                rec.Supervisor = Clean(Get(row, cSupervisor));
                rec.Geologist = Clean(Get(row, cGeologist));

                string srcId = Clean(Get(row, cSrcId));
                long lId;
                decimal dId;
                if (long.TryParse(srcId, NumberStyles.Integer, CultureInfo.InvariantCulture, out lId)) { rec.SourceSheetID = lId; }
                else if (decimal.TryParse(srcId, NumberStyles.Float, CultureInfo.InvariantCulture, out dId)) { rec.SourceSheetID = (long)dId; }

                if (string.IsNullOrEmpty(rec.SheetNo))
                {
                    rec.SheetNo = rec.SourceSheetID.HasValue ? set.Name + "-" + rec.SourceSheetID.Value : set.Name + "-" + rec.RowIndex;
                    rec.Warnings.Add("شمارهء برگه در فایل نبود؛ «" + rec.SheetNo + "» گذاشته شد.");
                }

                // سایر ستون‌ها
                for (int c = 0; c < dbf.FieldNames.Length; c++)
                {
                    if (mapped.Contains(c)) { continue; }
                    string v = Clean(Get(row, c));
                    if (v.Length > 0) { rec.ExtraAttributes[dbf.FieldNames[c]] = v; }
                }

                // هندسه
                ShapeGeometry g = shapes[i];
                if (g == null || g.Rings.Count == 0)
                {
                    result.Errors.Add(rec.Label + ": هندسه خالی است؛ رد شد.");
                    continue;
                }
                if (g.Rings.Count > 1)
                {
                    rec.Warnings.Add("چندضلعی " + g.Rings.Count + " حلقه دارد؛ فقط بزرگ‌ترین حلقهء بیرونی ذخیره شد.");
                }
                double[][] ring = g.LargestRing();
                if (ring.Length < 3)
                {
                    result.Errors.Add(rec.Label + ": حلقه کمتر از 3 رأس دارد؛ رد شد.");
                    continue;
                }

                // مساحت روی مختصات اصلی (اگر متر باشد دقیق‌تر است)
                double areaSrc = Math.Abs(SignedArea(ring));

                rec.MinLat = double.MaxValue; rec.MinLong = double.MaxValue; rec.MaxLat = double.MinValue; rec.MaxLong = double.MinValue;
                int last = ring.Length - 1;
                bool closed = Math.Abs(ring[0][0] - ring[last][0]) < 1e-9 && Math.Abs(ring[0][1] - ring[last][1]) < 1e-9;
                int count = closed ? ring.Length - 1 : ring.Length;    // رأس تکراری آخر ذخیره نمی‌شود (کد رسم خودش می‌بندد)
                for (int k = 0; k < count; k++)
                {
                    double lat, lng;
                    crs.ToLatLng(ring[k][0], ring[k][1], out lat, out lng);
                    if (double.IsNaN(lat) || double.IsNaN(lng) || Math.Abs(lat) > 90 || Math.Abs(lng) > 180)
                    {
                        rec.Warnings.Add("رأس " + (k + 1) + " خارج از محدودهء معتبر است.");
                        continue;
                    }
                    rec.Boundary.Add(new GeoPoint(Math.Round(lat, 6), Math.Round(lng, 6)));
                    if (lat < rec.MinLat) { rec.MinLat = lat; }
                    if (lat > rec.MaxLat) { rec.MaxLat = lat; }
                    if (lng < rec.MinLong) { rec.MinLong = lng; }
                    if (lng > rec.MaxLong) { rec.MaxLong = lng; }
                }
                if (rec.Boundary.Count < 3)
                {
                    result.Errors.Add(rec.Label + ": بعد از تبدیل مختصات کمتر از 3 رأس معتبر ماند؛ رد شد.");
                    continue;
                }

                double cLat, cLng;
                Centroid(rec.Boundary, out cLat, out cLng);
                rec.CentroidLat = Math.Round(cLat, 6);
                rec.CentroidLong = Math.Round(cLng, 6);
                rec.AreaKm2 = crs.IsProjectedMeters ? Math.Round(areaSrc / 1e6, 3) : Math.Round(ApproxAreaKm2(rec.Boundary), 3);

                result.Records.Add(rec);
            }
        }

        private static string Get(string[] row, int idx)
        {
            if (idx < 0 || idx >= row.Length) { return ""; }
            return row[idx] ?? "";
        }

        private static string Clean(string s)
        {
            if (s == null) { return ""; }
            s = s.Replace("\0", "").Trim();
            return s;
        }

        /// <summary>کد پروژه: فقط رقم‌ها (رقم فارسی/عربی به لاتین)، اعشار صفر «140411094252.000» حذف می‌شود</summary>
        public static string NormalizeProjectCode(string s)
        {
            if (s == null) { return ""; }
            s = s.Trim();
            if (s.Length == 0) { return ""; }
            StringBuilder sb = new StringBuilder();
            foreach (char ch in s)
            {
                if (ch >= '0' && ch <= '9') { sb.Append(ch); }
                else if (ch >= '۰' && ch <= '۹') { sb.Append((char)('0' + (ch - '۰'))); }
                else if (ch >= '٠' && ch <= '٩') { sb.Append((char)('0' + (ch - '٠'))); }
                else if (ch == '.' || ch == '٫') { break; }     // بخش اعشاری خروجی عددی dbf
            }
            return sb.ToString();
        }

        #endregion

        #region SHP

        private class ShapeGeometry
        {
            public List<double[][]> Rings = new List<double[][]>();

            public double[][] LargestRing()
            {
                double[][] best = null;
                double bestArea = -1;
                foreach (double[][] r in Rings)
                {
                    double a = Math.Abs(SignedArea(r));
                    if (a > bestArea) { bestArea = a; best = r; }
                }
                return best;
            }
        }

        private static int BE32(byte[] b, int p)
        {
            return (b[p] << 24) | (b[p + 1] << 16) | (b[p + 2] << 8) | b[p + 3];
        }

        private static List<ShapeGeometry> ReadShp(byte[] b)
        {
            List<ShapeGeometry> list = new List<ShapeGeometry>();
            if (b.Length < 100 || BE32(b, 0) != 9994) { throw new Exception("سرآیند shp نامعتبر است."); }
            int fileLenBytes = BE32(b, 24) * 2;
            int shapeType = BitConverter.ToInt32(b, 32);
            if (shapeType != 5 && shapeType != 15 && shapeType != 25 && shapeType != 0)
            {
                throw new Exception("نوع هندسهء لایه " + ShapeTypeName(shapeType) + " است؛ فقط Polygon پشتیبانی می‌شود.");
            }

            int p = 100;
            int end = Math.Min(fileLenBytes, b.Length);
            while (p + 8 <= end)
            {
                int contentLen = BE32(b, p + 4) * 2;
                int c = p + 8;
                if (c + 4 > b.Length) { break; }
                int st = BitConverter.ToInt32(b, c);
                ShapeGeometry g = new ShapeGeometry();
                if (st == 5 || st == 15 || st == 25)
                {
                    int numParts = BitConverter.ToInt32(b, c + 36);
                    int numPoints = BitConverter.ToInt32(b, c + 40);
                    int partsOff = c + 44;
                    int pointsOff = partsOff + 4 * numParts;
                    for (int i = 0; i < numParts; i++)
                    {
                        int start = BitConverter.ToInt32(b, partsOff + 4 * i);
                        int stop = (i + 1 < numParts) ? BitConverter.ToInt32(b, partsOff + 4 * (i + 1)) : numPoints;
                        double[][] ring = new double[Math.Max(0, stop - start)][];
                        for (int k = start; k < stop; k++)
                        {
                            ring[k - start] = new double[] { BitConverter.ToDouble(b, pointsOff + 16 * k), BitConverter.ToDouble(b, pointsOff + 16 * k + 8) };
                        }
                        g.Rings.Add(ring);
                    }
                }
                else if (st != 0)
                {
                    g = null;   // نوع دیگر (نقطه/خط) - در ParseLayer به‌عنوان «هندسه خالی» گزارش می‌شود
                }
                list.Add(g);
                p = c + contentLen;
            }
            return list;
        }

        private static string ShapeTypeName(int t)
        {
            switch (t)
            {
                case 0: return "Null";
                case 1: return "Point";
                case 3: return "PolyLine";
                case 5: return "Polygon";
                case 8: return "MultiPoint";
                case 11: return "PointZ";
                case 13: return "PolyLineZ";
                case 15: return "PolygonZ";
                case 18: return "MultiPointZ";
                case 21: return "PointM";
                case 23: return "PolyLineM";
                case 25: return "PolygonM";
                case 28: return "MultiPointM";
                case 31: return "MultiPatch";
                default: return t.ToString();
            }
        }

        /// <summary>مساحت علامت‌دار (shoelace)؛ در Shapefile حلقهء بیرونی ساعتگرد (منفی) است</summary>
        private static double SignedArea(double[][] ring)
        {
            double a = 0;
            int n = ring.Length;
            for (int i = 0; i < n; i++)
            {
                double[] p1 = ring[i];
                double[] p2 = ring[(i + 1) % n];
                a += p1[0] * p2[1] - p2[0] * p1[1];
            }
            return a / 2.0;
        }

        private static void Centroid(List<GeoPoint> pts, out double lat, out double lng)
        {
            // مرکز هندسی چندضلعی؛ اگر تباهیده بود میانگین رئوس
            double a = 0, cx = 0, cy = 0;
            int n = pts.Count;
            for (int i = 0; i < n; i++)
            {
                GeoPoint p1 = pts[i];
                GeoPoint p2 = pts[(i + 1) % n];
                double f = p1.lng * p2.lat - p2.lng * p1.lat;
                a += f;
                cx += (p1.lng + p2.lng) * f;
                cy += (p1.lat + p2.lat) * f;
            }
            if (Math.Abs(a) < 1e-12)
            {
                double sLat = 0, sLng = 0;
                foreach (GeoPoint p in pts) { sLat += p.lat; sLng += p.lng; }
                lat = sLat / n; lng = sLng / n;
                return;
            }
            a *= 0.5;
            lng = cx / (6 * a);
            lat = cy / (6 * a);
        }

        /// <summary>مساحت تقریبی روی درجهء اعشاری (تصویر هم‌فاصلهء محلی)</summary>
        private static double ApproxAreaKm2(List<GeoPoint> pts)
        {
            double lat0 = 0;
            foreach (GeoPoint p in pts) { lat0 += p.lat; }
            lat0 = lat0 / pts.Count * Math.PI / 180.0;
            double kx = 111.32 * Math.Cos(lat0), ky = 110.57;
            double a = 0;
            int n = pts.Count;
            for (int i = 0; i < n; i++)
            {
                GeoPoint p1 = pts[i];
                GeoPoint p2 = pts[(i + 1) % n];
                a += (p1.lng * kx) * (p2.lat * ky) - (p2.lng * kx) * (p1.lat * ky);
            }
            return Math.Abs(a / 2.0);
        }

        #endregion

        #region DBF

        private class DbfTable
        {
            public string[] FieldNames;
            public char[] FieldTypes;
            public List<string[]> Rows = new List<string[]>();
            public string EncodingName;
        }

        private static Encoding ResolveEncoding(byte[] cpg, byte[] dbf)
        {
            // 1) فایل cpg
            if (cpg != null && cpg.Length > 0)
            {
                string name = Encoding.ASCII.GetString(cpg).Trim().Trim('\0', '\r', '\n', ' ');
                Encoding e = TryEncoding(name);
                if (e != null) { return e; }
            }
            // 2) بایت LDID در سرآیند dbf (چند مقدار رایج)
            if (dbf != null && dbf.Length > 29)
            {
                switch (dbf[29])
                {
                    case 0x57: return Encoding.GetEncoding(1252);   // ANSI Windows
                    case 0x7D: return Encoding.GetEncoding(1256);   // Windows Arabic
                    case 0x03: return Encoding.GetEncoding(1252);
                }
            }
            // 3) اگر متن UTF-8 معتبر بود همان؛ وگرنه 1256 (فارسی قدیمی)
            if (dbf != null)
            {
                try
                {
                    new UTF8Encoding(false, true).GetString(dbf, Math.Min(32, dbf.Length), Math.Max(0, Math.Min(dbf.Length, 4096) - 32));
                    return Encoding.UTF8;
                }
                catch (Exception) { }
            }
            return Encoding.GetEncoding(1256);
        }

        private static Encoding TryEncoding(string name)
        {
            if (string.IsNullOrEmpty(name)) { return null; }
            string n = name.ToUpperInvariant().Replace("_", "-");
            try
            {
                if (n == "UTF-8" || n == "UTF8") { return Encoding.UTF8; }
                int cp;
                if (int.TryParse(n, out cp)) { return Encoding.GetEncoding(cp); }
                if (n.StartsWith("CP") && int.TryParse(n.Substring(2), out cp)) { return Encoding.GetEncoding(cp); }
                if (n.StartsWith("WINDOWS-") && int.TryParse(n.Substring(8), out cp)) { return Encoding.GetEncoding(cp); }
                return Encoding.GetEncoding(name);
            }
            catch (Exception)
            {
                return null;
            }
        }

        private static DbfTable ReadDbf(byte[] b, byte[] cpg)
        {
            if (b.Length < 32) { throw new Exception("سرآیند dbf نامعتبر است."); }
            Encoding enc = ResolveEncoding(cpg, b);
            DbfTable t = new DbfTable();
            t.EncodingName = enc.WebName;

            int numRecords = BitConverter.ToInt32(b, 4);
            int headerLen = BitConverter.ToUInt16(b, 8);
            int recordLen = BitConverter.ToUInt16(b, 10);

            List<string> names = new List<string>();
            List<char> types = new List<char>();
            List<int> lens = new List<int>();
            int p = 32;
            while (p + 32 <= headerLen && b[p] != 0x0D)
            {
                int nameLen = 0;
                while (nameLen < 11 && b[p + nameLen] != 0) { nameLen++; }
                string name;
                try { name = enc.GetString(b, p, nameLen).Trim(); }
                catch (Exception) { name = Encoding.ASCII.GetString(b, p, nameLen).Trim(); }
                if (name.Length == 0) { name = "COL" + names.Count; }
                names.Add(name);
                types.Add((char)b[p + 11]);
                lens.Add(b[p + 16]);
                p += 32;
            }
            t.FieldNames = names.ToArray();
            t.FieldTypes = types.ToArray();

            int rp = headerLen;
            for (int r = 0; r < numRecords; r++)
            {
                if (rp + recordLen > b.Length) { break; }
                if (b[rp] == 0x2A) { rp += recordLen; continue; }   // رکورد حذف‌شده
                string[] row = new string[names.Count];
                int off = rp + 1;
                for (int c = 0; c < names.Count; c++)
                {
                    int len = lens[c];
                    string val;
                    if (types[c] == 'M' || types[c] == 'B' || types[c] == 'G')
                    {
                        val = "";
                    }
                    else
                    {
                        try { val = enc.GetString(b, off, len); }
                        catch (Exception) { val = Encoding.ASCII.GetString(b, off, len); }
                        val = val.Replace("\0", "").Trim();
                        if (types[c] == 'D' && val.Length == 8)
                        {
                            val = val.Substring(0, 4) + "-" + val.Substring(4, 2) + "-" + val.Substring(6, 2);
                        }
                        else if ((types[c] == 'N' || types[c] == 'F') && val.Length > 0)
                        {
                            decimal d;
                            if (decimal.TryParse(val, NumberStyles.Float, CultureInfo.InvariantCulture, out d))
                            {
                                val = (d == decimal.Truncate(d)) ? decimal.Truncate(d).ToString(CultureInfo.InvariantCulture) : d.ToString(CultureInfo.InvariantCulture);
                            }
                        }
                        else if (types[c] == 'L')
                        {
                            val = (val == "T" || val == "t" || val == "Y" || val == "y") ? "1" : (val.Length == 0 || val == "?" ? "" : "0");
                        }
                    }
                    row[c] = val;
                    off += len;
                }
                t.Rows.Add(row);
                rp += recordLen;
            }
            return t;
        }

        #endregion

        #region PRJ / تبدیل مختصات

        private class CrsInfo
        {
            public string Name = "نامشخص";
            public bool Supported;
            public bool IsProjectedMeters;
            public string Warning;

            // پارامترهای Transverse Mercator
            public bool IsTm;
            public double A = 6378137.0;
            public double InvF = 298.257223563;
            public double K0 = 0.9996;
            public double Lon0 = 0;       // درجه
            public double Lat0 = 0;       // درجه
            public double FE = 500000;
            public double FN = 0;
            public double UnitToMeter = 1.0;

            public void ToLatLng(double x, double y, out double lat, out double lng)
            {
                if (!IsTm)
                {
                    lng = x; lat = y;
                    return;
                }
                InverseTm(x * UnitToMeter, y * UnitToMeter, out lat, out lng);
            }

            private void InverseTm(double E, double N, out double latDeg, out double lonDeg)
            {
                double a = A;
                double f = 1.0 / InvF;
                double e2 = f * (2 - f);
                double ep2 = e2 / (1 - e2);
                double lon0 = Lon0 * Math.PI / 180.0;
                double lat0 = Lat0 * Math.PI / 180.0;

                double m0 = MeridianArc(a, e2, lat0);
                double M = m0 + (N - FN) / K0;
                double mu = M / (a * (1 - e2 / 4 - 3 * e2 * e2 / 64 - 5 * e2 * e2 * e2 / 256));
                double e1 = (1 - Math.Sqrt(1 - e2)) / (1 + Math.Sqrt(1 - e2));
                double phi1 = mu
                    + (3 * e1 / 2 - 27 * Math.Pow(e1, 3) / 32) * Math.Sin(2 * mu)
                    + (21 * e1 * e1 / 16 - 55 * Math.Pow(e1, 4) / 32) * Math.Sin(4 * mu)
                    + (151 * Math.Pow(e1, 3) / 96) * Math.Sin(6 * mu)
                    + (1097 * Math.Pow(e1, 4) / 512) * Math.Sin(8 * mu);

                double sinP = Math.Sin(phi1), cosP = Math.Cos(phi1), tanP = Math.Tan(phi1);
                double N1 = a / Math.Sqrt(1 - e2 * sinP * sinP);
                double T1 = tanP * tanP;
                double C1 = ep2 * cosP * cosP;
                double R1 = a * (1 - e2) / Math.Pow(1 - e2 * sinP * sinP, 1.5);
                double D = (E - FE) / (N1 * K0);

                double lat = phi1 - (N1 * tanP / R1) * (
                      D * D / 2
                    - (5 + 3 * T1 + 10 * C1 - 4 * C1 * C1 - 9 * ep2) * Math.Pow(D, 4) / 24
                    + (61 + 90 * T1 + 298 * C1 + 45 * T1 * T1 - 252 * ep2 - 3 * C1 * C1) * Math.Pow(D, 6) / 720);
                double lon = lon0 + (
                      D
                    - (1 + 2 * T1 + C1) * Math.Pow(D, 3) / 6
                    + (5 - 2 * C1 + 28 * T1 - 3 * C1 * C1 + 8 * ep2 + 24 * T1 * T1) * Math.Pow(D, 5) / 120) / cosP;

                latDeg = lat * 180.0 / Math.PI;
                lonDeg = lon * 180.0 / Math.PI;
            }

            private static double MeridianArc(double a, double e2, double phi)
            {
                return a * ((1 - e2 / 4 - 3 * e2 * e2 / 64 - 5 * e2 * e2 * e2 / 256) * phi
                    - (3 * e2 / 8 + 3 * e2 * e2 / 32 + 45 * e2 * e2 * e2 / 1024) * Math.Sin(2 * phi)
                    + (15 * e2 * e2 / 256 + 45 * e2 * e2 * e2 / 1024) * Math.Sin(4 * phi)
                    - (35 * e2 * e2 * e2 / 3072) * Math.Sin(6 * phi));
            }
        }

        private static double? WktParam(string wkt, string name)
        {
            Match m = Regex.Match(wkt, "PARAMETER\\[\\s*[\"']" + Regex.Escape(name) + "[\"']\\s*,\\s*([-+0-9.eE]+)", RegexOptions.IgnoreCase);
            if (!m.Success) { return null; }
            return double.Parse(m.Groups[1].Value, CultureInfo.InvariantCulture);
        }

        private static CrsInfo ParseCrs(byte[] prj)
        {
            CrsInfo c = new CrsInfo();
            if (prj == null || prj.Length == 0)
            {
                // بدون prj: فرض درجهء اعشاری (در ParseLayer هر رأس خارج از محدوده هشدار می‌گیرد)
                c.Name = "بدون prj (فرض: درجهء اعشاری WGS84)";
                c.Supported = true;
                c.Warning = "فایل prj در ZIP نبود؛ مختصات به‌عنوان درجهء اعشاری WGS84 خوانده شد.";
                return c;
            }
            string wkt = Encoding.UTF8.GetString(prj).Trim().TrimStart('﻿');
            Match mName = Regex.Match(wkt, "^\\s*(PROJCS|GEOGCS)\\[\\s*[\"']([^\"']*)[\"']", RegexOptions.IgnoreCase);
            string kind = mName.Success ? mName.Groups[1].Value.ToUpperInvariant() : "";
            c.Name = mName.Success ? mName.Groups[2].Value : wkt.Substring(0, Math.Min(60, wkt.Length));

            Match mSph = Regex.Match(wkt, "SPHEROID\\[\\s*[\"'][^\"']*[\"']\\s*,\\s*([-+0-9.eE]+)\\s*,\\s*([-+0-9.eE]+)", RegexOptions.IgnoreCase);
            if (mSph.Success)
            {
                c.A = double.Parse(mSph.Groups[1].Value, CultureInfo.InvariantCulture);
                c.InvF = double.Parse(mSph.Groups[2].Value, CultureInfo.InvariantCulture);
            }
            bool wgs84 = Regex.IsMatch(wkt, "DATUM\\[\\s*[\"']D?_?WGS_?1984", RegexOptions.IgnoreCase);

            if (kind == "GEOGCS")
            {
                c.Supported = true;
                c.IsTm = false;
                if (!wgs84) { c.Warning = "مبنای (datum) لایه WGS84 نیست (" + c.Name + ")؛ جابه‌جایی مبنا اعمال نشد و ممکن است چند ده متر خطا داشته باشد."; }
                return c;
            }
            if (kind == "PROJCS")
            {
                Match mProj = Regex.Match(wkt, "PROJECTION\\[\\s*[\"']([^\"']*)[\"']", RegexOptions.IgnoreCase);
                string proj = mProj.Success ? mProj.Groups[1].Value : "";
                if (proj.IndexOf("Transverse_Mercator", StringComparison.OrdinalIgnoreCase) < 0)
                {
                    c.Supported = false;
                    c.Name = c.Name + " / " + proj;
                    return c;
                }
                c.IsTm = true;
                c.Supported = true;
                c.IsProjectedMeters = true;
                c.K0 = WktParam(wkt, "Scale_Factor") ?? 0.9996;
                c.Lon0 = WktParam(wkt, "Central_Meridian") ?? 0;
                c.Lat0 = WktParam(wkt, "Latitude_Of_Origin") ?? 0;
                c.FE = WktParam(wkt, "False_Easting") ?? 0;
                c.FN = WktParam(wkt, "False_Northing") ?? 0;

                // واحد طول (آخرین UNIT در WKT مربوط به PROJCS است)
                MatchCollection units = Regex.Matches(wkt, "UNIT\\[\\s*[\"']([^\"']*)[\"']\\s*,\\s*([-+0-9.eE]+)", RegexOptions.IgnoreCase);
                if (units.Count > 0)
                {
                    Match u = units[units.Count - 1];
                    double factor = double.Parse(u.Groups[2].Value, CultureInfo.InvariantCulture);
                    if (factor > 0.5 && factor < 2) { c.UnitToMeter = factor; }   // Meter=1 ، Foot=0.3048 هم قابل قبول
                    else if (factor > 0) { c.UnitToMeter = factor; }
                }
                if (!wgs84) { c.Warning = "مبنای (datum) لایه WGS84 نیست (" + c.Name + ")؛ جابه‌جایی مبنا اعمال نشد و ممکن است چند ده متر خطا داشته باشد."; }
                return c;
            }

            c.Supported = false;
            return c;
        }

        #endregion
    }
}
