using System;
using System.Runtime.InteropServices;
using Microsoft.SharePoint;

namespace Sazmanyar.GIS.Features.Feature_Sazmanyar_GIS_Web
{
    /// <summary>
    /// فیچر سطح Web: روی هر وبی که فعال شود (مثلاً ساب‌سایت GIS) لیست‌های مورد نیاز
    /// وب‌پارت‌های GIS را در همان وب می‌سازد - فقط اگر از قبل وجود نداشته باشند.
    /// </summary>
    /// <remarks>
    /// The GUID attached to this class may be used during packaging and should not be modified.
    ///
    /// چهار لیست اول معادل کدنویسی‌شدهء چهار قالب قدیمی STP (ListPolygans، ListProject، ListRouts،
    /// ListStations) هستند که دیگر در پروژه نگهداری نمی‌شوند؛ ستون‌ها و نوع دقیق آن‌ها از manifest.xml
    /// همان قالب‌ها استخراج شده و این کد تنها مرجع ساختار لیست‌هاست.
    /// لیست پنجم (گزارش‌های طرح) STP نداشت و ستون‌هایش از کد ClsHelpper.FetchAllReportsByProjectName
    /// استخراج شده است.
    ///
    /// کد رانتایم (ClsHelpper) همیشه لیست‌ها را از SPContext.Current.Web می‌خواند، بنابراین
    /// صفحات وب‌پارت باید روی همان وبی ساخته شوند که این فیچر رویش فعال شده است.
    /// </remarks>

    [Guid("86f4d6de-9e4e-41b1-9fd1-70aa97fdb8fe")]
    public class Feature_Sazmanyar_GIS_WebEventReceiver : SPFeatureReceiver
    {
        // نام (آخرین بخش URL) ساب‌سایتی که لیست‌ها فقط روی آن ساخته می‌شوند
        private const string GisSubsiteName = "GIS";

        public override void FeatureActivated(SPFeatureReceiverProperties properties)
        {
            SPWeb currentWeb = (SPWeb)properties.Feature.Parent;

            if (currentWeb.IsRootWeb
                || !string.Equals(currentWeb.Name, GisSubsiteName, StringComparison.OrdinalIgnoreCase))
            {
                // روی سایت اصلی یا سایر ساب‌سایت‌ها هیچ لیستی ساخته نمی‌شود.
                return;
            }

            Guid siteId = currentWeb.Site.ID;
            Guid webId = currentWeb.ID;

            SPSecurity.RunWithElevatedPrivileges(delegate ()
            {
                using (SPSite site = new SPSite(siteId))
                {
                    using (SPWeb web = site.OpenWeb(webId))
                    {
                        site.AllowUnsafeUpdates = true;
                        web.AllowUnsafeUpdates = true;

                        // ListRouts به ListStations وابسته است (دو ستون Lookup به آن دارد)،
                        // به همین دلیل ListStations باید زودتر ساخته شود.
                        SPList listStations = CreateListIfMissing_ListStations(web);
                        CreateListIfMissing_ListPolygans(web);
                        CreateListIfMissing_ListProject(web);
                        CreateListIfMissing_ListRouts(web, listStations);
                        CreateListIfMissing_ListReports(web);
                    }
                }
            });
        }

        // ==================================================================
        // لیست سطح ها (ListPolygans.stp)
        // ==================================================================
        private static void CreateListIfMissing_ListPolygans(SPWeb web)
        {
            const string listTitle = ClsHelpper.Const_ListPolygans_Title;

            if (web.Lists.TryGetList(listTitle) != null)
            {
                return;
            }

            try
            {
                // ابتدا با نام انگلیسی ساخته می‌شود تا URL لیست تمیز و انگلیسی بماند
                // (Lists/ListPolygans)، سپس Title آن به فارسی تغییر می‌کند.
                Guid listId = web.Lists.Add("ListPolygans", "لیست سطح‌ها (ساخته‌شده به‌صورت خودکار هنگام فعال‌سازی فیچر)", SPListTemplateType.GenericList);
                SPList list = web.Lists[listId];
                list.Title = listTitle;
                list.Update();

                AddNoteField(list, "PolygonPoints", "نقاط سطح", numLines: 6);
                AddTextField(list, "FillColor", "رنگ داخل سطح", maxLength: 255);
                AddTextField(list, "BorderColor", "رنگ دور سطح", maxLength: 255);
                AddTextField(list, "Opacity", "روشنایی", maxLength: 255);

                list.OnQuickLaunch = true;
                list.Update();

                SetDefaultView(list, "PolygonPoints", "FillColor", "BorderColor", "Opacity");
            }
            catch (Exception)
            {
                // اگر ساخت این لیست شکست بخورد، بقیهء لیست‌ها همچنان ساخته می‌شوند.
            }
        }

        // ==================================================================
        // لیست پروژه ها (ListProject.stp)
        // ==================================================================
        private static void CreateListIfMissing_ListProject(SPWeb web)
        {
            const string listTitle = ClsHelpper.Const_ListProject_Title;

            if (web.Lists.TryGetList(listTitle) != null)
            {
                return;
            }

            try
            {
                Guid listId = web.Lists.Add("ListProject", "لیست پروژه‌ها (ساخته‌شده به‌صورت خودکار هنگام فعال‌سازی فیچر)", SPListTemplateType.GenericList);
                SPList list = web.Lists[listId];
                list.Title = listTitle;
                list.Update();

                AddMapPointFields(list);

                list.OnQuickLaunch = true;
                list.Update();

                SetDefaultView(list, "Latitude", "Longitude", "Description", "State", "IsCenter");
            }
            catch (Exception)
            {
            }
        }

        // ==================================================================
        // لیست ایستگاه ها (ListStations.stp)
        // ==================================================================
        private static SPList CreateListIfMissing_ListStations(SPWeb web)
        {
            const string listTitle = ClsHelpper.Const_ListStations_Title;

            SPList list = web.Lists.TryGetList(listTitle);
            if (list != null)
            {
                return list;
            }

            try
            {
                Guid listId = web.Lists.Add("ListStations", "لیست ایستگاه‌ها (ساخته‌شده به‌صورت خودکار هنگام فعال‌سازی فیچر)", SPListTemplateType.GenericList);
                list = web.Lists[listId];
                list.Title = listTitle;
                list.Update();

                AddMapPointFields(list);

                list.OnQuickLaunch = true;
                list.Update();

                SetDefaultView(list, "Latitude", "Longitude", "Description", "State", "IsCenter");

                return list;
            }
            catch (Exception)
            {
                // اگر ساخت این لیست شکست بخورد، دیگر نمی‌توانیم ListRouts را با Lookup صحیح بسازیم.
                return web.Lists.TryGetList(listTitle);
            }
        }

        // ListPolygans و ListProject و ListStations هر سه دقیقاً همین ۵ ستون را دارند
        // (Latitude, Longitude, Description, State, IsCenter) — دقیقاً مثل "Google Map List"
        // در پروژهء Sazmanyar.GoogleMapOffline.
        private static void AddMapPointFields(SPList list)
        {
            AddNumberField(list, "Latitude", "Latitude");
            AddNumberField(list, "Longitude", "Longitude");
            AddTextField(list, "Description", "Description", maxLength: 255);
            AddChoiceField(list, "State", "State", defaultValue: "Blue", fillInChoice: false, choices: new[] { "Blue", "Green", "Red" });
            AddBooleanField(list, "IsCenter", "IsCenter", defaultValue: true);
        }

        // ==================================================================
        // لیست مسیرها (ListRouts.stp) — به ListStations وابسته است
        // ==================================================================
        private static void CreateListIfMissing_ListRouts(SPWeb web, SPList listStations)
        {
            const string listTitle = ClsHelpper.Const_ListRouts_Title;

            if (web.Lists.TryGetList(listTitle) != null)
            {
                return;
            }

            if (listStations == null)
            {
                // بدون ListStations نمی‌توان ستون‌های Lookup (ایستگاه مبدا/مقصد) را ساخت
                return;
            }

            try
            {
                Guid listId = web.Lists.Add("ListRouts", "لیست مسیرها (ساخته‌شده به‌صورت خودکار هنگام فعال‌سازی فیچر)", SPListTemplateType.GenericList);
                SPList list = web.Lists[listId];
                list.Title = listTitle;
                list.Update();

                // باید Choice باشد: ClsHelpper.GetProjectNameDataTable گزینه‌های همین ستون را می‌خواند و
                // به‌عنوان لیست «نام پروژه» در فرم ثبت مسیر نشان می‌دهد. FillInChoice=TRUE تا ثبت مسیر
                // با نام پروژه‌ای که هنوز در گزینه‌ها نیست هم شکست نخورد. گزینه‌ها را مدیر در تنظیمات
                // ستون اضافه می‌کند.
                AddChoiceField(list, "ProgramName", "ProgramName", defaultValue: null, fillInChoice: true);
                AddNoteField(list, "Points", "مسیر", numLines: 6);
                AddTextField(list, "strDistance", "strDistance", maxLength: 255);
                AddTextField(list, "strDuration", "strDuration", maxLength: 255);
                AddTextField(list, "LatNortheast", "LatNortheast", maxLength: 255);
                AddTextField(list, "LongNortheast", "LongNortheast", maxLength: 255);
                AddTextField(list, "LatSouthwest", "LatSouthwest", maxLength: 255);
                AddTextField(list, "LongSouthwest", "LongSouthwest", maxLength: 255);
                AddNumberField(list, "PlaneDistanceMap", "PlaneDistanceMap");
                AddNumberField(list, "PlaneDistanceChart", "PlaneDistanceChart");
                AddTextField(list, "TYPE_x002f_NAME", "TYPE/NAME", maxLength: 255);
                AddNumberField(list, "NUMBER_x0020_CORE", "NUMBER CORE");
                AddNumberField(list, "ReduceCore1", "ReduceCore1");
                AddNumberField(list, "ReduceCore2", "ReduceCore2");
                AddLookupField(list, "StartStation", "ایستگاه مبدا", listStations, "Title");
                AddLookupField(list, "EndStation", "ایستگاه مقصد", listStations, "Title");

                list.OnQuickLaunch = true;
                list.Update();

                SetDefaultView(list, "ProgramName", "StartStation", "EndStation", "Points",
                    "strDistance", "strDuration", "TYPE_x002f_NAME");
            }
            catch (Exception)
            {
            }
        }

        // ==================================================================
        // لیست گزارش های طرح — خوانده‌شده در ClsHelpper.FetchAllReportsByProjectName:
        // فیلتر Contains روی ProgramName و نمایش Title به‌عنوان لینک به URLInfo
        // ==================================================================
        private static void CreateListIfMissing_ListReports(SPWeb web)
        {
            const string listTitle = ClsHelpper.Const_ListReports_Title;

            if (web.Lists.TryGetList(listTitle) != null)
            {
                return;
            }

            try
            {
                Guid listId = web.Lists.Add("ListReports", "لیست گزارش‌های طرح (ساخته‌شده به‌صورت خودکار هنگام فعال‌سازی فیچر)", SPListTemplateType.GenericList);
                SPList list = web.Lists[listId];
                list.Title = listTitle;
                list.Update();

                AddTextField(list, "ProgramName", "نام طرح", maxLength: 255);
                AddTextField(list, "URLInfo", "آدرس گزارش", maxLength: 255);

                list.OnQuickLaunch = true;
                list.Update();

                SetDefaultView(list, "ProgramName", "URLInfo");
            }
            catch (Exception)
            {
            }
        }

        // ==================================================================
        // کمک‌کننده‌های ساخت ستون (CAML دقیقاً معادل چیزی که در STP بود، بدون ID/ColName
        // داخلی قدیمی که مخصوص همان سایت اصلی بودند و اینجا کاربردی ندارند)
        // ==================================================================

        private static void AddTextField(SPList list, string internalName, string displayName, int maxLength)
        {
            string caml = string.Format(
                "<Field Type=\"Text\" Name=\"{0}\" StaticName=\"{0}\" DisplayName=\"{1}\" Required=\"FALSE\" MaxLength=\"{2}\" />",
                internalName, EscapeXmlAttribute(displayName), maxLength);
            list.Fields.AddFieldAsXml(caml, true, SPAddFieldOptions.AddFieldInternalNameHint);
        }

        private static void AddNoteField(SPList list, string internalName, string displayName, int numLines)
        {
            string caml = string.Format(
                "<Field Type=\"Note\" Name=\"{0}\" StaticName=\"{0}\" DisplayName=\"{1}\" Required=\"FALSE\" NumLines=\"{2}\" RichText=\"FALSE\" RichTextMode=\"Compatible\" />",
                internalName, EscapeXmlAttribute(displayName), numLines);
            list.Fields.AddFieldAsXml(caml, true, SPAddFieldOptions.AddFieldInternalNameHint);
        }

        private static void AddNumberField(SPList list, string internalName, string displayName)
        {
            string caml = string.Format(
                "<Field Type=\"Number\" Name=\"{0}\" StaticName=\"{0}\" DisplayName=\"{1}\" Required=\"FALSE\" />",
                internalName, EscapeXmlAttribute(displayName));
            list.Fields.AddFieldAsXml(caml, true, SPAddFieldOptions.AddFieldInternalNameHint);
        }

        private static void AddBooleanField(SPList list, string internalName, string displayName, bool defaultValue)
        {
            string caml = string.Format(
                "<Field Type=\"Boolean\" Name=\"{0}\" StaticName=\"{0}\" DisplayName=\"{1}\"><Default>{2}</Default></Field>",
                internalName, EscapeXmlAttribute(displayName), defaultValue ? "1" : "0");
            list.Fields.AddFieldAsXml(caml, true, SPAddFieldOptions.AddFieldInternalNameHint);
        }

        private static void AddChoiceField(SPList list, string internalName, string displayName, string defaultValue, bool fillInChoice = false, params string[] choices)
        {
            System.Text.StringBuilder choicesXml = new System.Text.StringBuilder();
            foreach (string choice in choices)
            {
                choicesXml.Append("<CHOICE>").Append(EscapeXmlAttribute(choice)).Append("</CHOICE>");
            }

            string defaultXml = string.IsNullOrEmpty(defaultValue)
                ? string.Empty
                : "<Default>" + EscapeXmlAttribute(defaultValue) + "</Default>";

            string caml = string.Format(
                "<Field Type=\"Choice\" Name=\"{0}\" StaticName=\"{0}\" DisplayName=\"{1}\" Required=\"FALSE\" Format=\"Dropdown\" FillInChoice=\"{2}\">{3}<CHOICES>{4}</CHOICES></Field>",
                internalName, EscapeXmlAttribute(displayName), fillInChoice ? "TRUE" : "FALSE", defaultXml, choicesXml);
            list.Fields.AddFieldAsXml(caml, true, SPAddFieldOptions.AddFieldInternalNameHint);
        }

        private static void AddLookupField(SPList list, string internalName, string displayName, SPList targetList, string showField)
        {
            string caml = string.Format(
                "<Field Type=\"Lookup\" Name=\"{0}\" StaticName=\"{0}\" DisplayName=\"{1}\" Required=\"FALSE\" List=\"{2}\" ShowField=\"{3}\" RelationshipDeleteBehavior=\"None\" />",
                internalName, EscapeXmlAttribute(displayName), targetList.ID.ToString("B"), showField);
            list.Fields.AddFieldAsXml(caml, true, SPAddFieldOptions.AddFieldInternalNameHint);
        }

        private static void SetDefaultView(SPList list, params string[] customFieldInternalNames)
        {
            // نمای پیش‌فرض لیست‌های Generic از قبل ستون LinkTitle (عنوان با لینک/منو) را دارد؛
            // افزودن Title جداگانه باعث نمایش دو ستون عنوان می‌شد.
            SPView defaultView = list.DefaultView;

            foreach (string fieldName in customFieldInternalNames)
            {
                if (!defaultView.ViewFields.Exists(fieldName))
                {
                    TryAddViewField(defaultView, fieldName);
                }
            }

            try
            {
                defaultView.Update();
            }
            catch (Exception)
            {
                // نمایش پیش‌فرض صرفاً برای راحتی کاربر است؛ اگر ذخیره نشود لیست همچنان قابل استفاده است.
            }
        }

        private static void TryAddViewField(SPView view, string fieldName)
        {
            try
            {
                view.ViewFields.Add(fieldName);
            }
            catch (Exception)
            {
                // اگر افزودن یک ستون به نما شکست بخورد، بقیهء ستون‌ها همچنان اضافه می‌شوند.
            }
        }

        private static string EscapeXmlAttribute(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                return string.Empty;
            }

            return value
                .Replace("&", "&amp;")
                .Replace("\"", "&quot;")
                .Replace("<", "&lt;")
                .Replace(">", "&gt;");
        }
    }
}
