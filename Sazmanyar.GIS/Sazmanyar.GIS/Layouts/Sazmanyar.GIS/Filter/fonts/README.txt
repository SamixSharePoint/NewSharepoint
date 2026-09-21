فونت IRANSansWeb برای صفحه‌های جستجوی پیشرفته (Filter*.html)
=============================================================
فایل‌های زیر را در همین پوشه بگذارید (نام‌ها دقیقاً همین باشد؛ فرمت‌هایی که ندارید را می‌توانید نگذارید، مرورگرهای امروزی woff2/woff را می‌خوانند):

    IRANSansWeb.woff2        IRANSansWeb.woff        IRANSansWeb.ttf        IRANSansWeb.eot
    IRANSansWeb_Bold.woff2   IRANSansWeb_Bold.woff   IRANSansWeb_Bold.ttf   IRANSansWeb_Bold.eot

سپس در Visual Studio روی پوشهء fonts راست‌کلیک -> Add -> Existing Item تا به پروژه اضافه شوند (در csproj به‌صورت
<Content Include="Layouts\Sazmanyar.GIS\Filter\fonts\...">) و با استقرار راه‌حل به سرور کپی شوند.

تعریف @font-face در css\gis-filter.css و انتخاب فونت در js\gis-filter.js (GIS_FILTER_FIXED_FONT) است.
اگر فایل‌ها نباشند، صفحه با Tahoma نمایش داده می‌شود و خطایی رخ نمی‌دهد.
