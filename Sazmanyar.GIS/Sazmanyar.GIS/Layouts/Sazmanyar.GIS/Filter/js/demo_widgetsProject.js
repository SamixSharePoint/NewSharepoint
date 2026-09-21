// تعریف فیلترهای جستجوی پروژه‌های PWA (جدول PWAInfo) برای وب‌پارت ShowAllProjectInfo
// الگو: demo_widgetsSath.js — شناسهء هر فیلتر دقیقاً نام ستون PWAInfo است؛ خروجی getSQL به سرور می‌رود و
// به شرط WHERE اضافه می‌شود. مقادیر متنی با پیشوند NNNNNNNNNNN (→ N'...') و تاریخ‌ها با DDDDDDDDDDD علامت می‌خورند.

// Fix for Selectize
$('#builder-widgets').on('afterCreateRuleInput.queryBuilder', function (e, rule) {
    if (rule.filter.plugin == 'selectize') {
        rule.$el.find('.rule-value-container').css('min-width', '200px')
      .find('.selectize-control').removeClass('form-control');
    }
});

var DarsadValue = [{ 'id': 1, 'name': 'بیش از 90 درصد' }, { 'id': 2, 'name': 'بین 70 تا 90 درصد' }, { 'id': 3, 'name': 'بین 50 تا 70 درصد' }, { 'id': 4, 'name': 'کمتر از 50 درصد' }, { 'id': 5, 'name': 'آغاز نشده' }];
var StatusValue = [{ 'id': 'در حال اجرا', 'name': 'در حال اجرا' }, { 'id': 'بدون وضعیت', 'name': 'بدون وضعیت' }];
var ExecutionValue = [{ 'id': 'امانی', 'name': 'امانی' }, { 'id': 'پیمانی', 'name': 'پیمانی' }];

// فهرست نوع‌ها و منطقه‌ها از صفحهء مادر (همان مقادیری که در کمبو و پیشنهاد خودکار بالای نقشه هستند)
var ParentLists = { types: [], regions: [] };
try {
    if (parent && typeof parent.pwaFilterLists == 'function') {
        ParentLists = parent.pwaFilterLists() || ParentLists;
    }
} catch (e) { }
function toOptions(arr) {
    var out = [];
    for (var i = 0; i < (arr || []).length; i++) { out.push({ 'id': arr[i], 'name': arr[i] }); }
    return out;
}
var TypeValue = toOptions(ParentLists.types);
var RegionValue = toOptions(ParentLists.regions);

function selectizeFilter(id, label, values, type, operators) {
    return {
        id: id,
        label: label,
        type: type || 'string',
        operators: operators || ['equal', 'not_equal'],
        plugin: 'selectize',
        plugin_config: {
            valueField: 'id',
            labelField: 'name',
            searchField: 'name',
            sortField: 'id',
            create: true,
            maxItems: 1,
            plugins: ['remove_button'],
            onInitialize: function () {
                var that = this;
                values.forEach(function (item) {
                    that.addOption(item);
                });
            }
        },
        valueSetter: function (rule, value) {
            rule.$el.find('.rule-value-container input')[0].selectize.setValue(value);
        }
    };
}

function sliderFilter(id, label) {
    return {
        id: id,
        label: label,
        type: 'integer',
        operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between'],
        validation: { min: 0, max: 100 },
        plugin: 'slider',
        plugin_config: { min: 0, max: 100, value: 0 },
        valueSetter: function (rule, value) {
            if (rule.operator.nb_inputs == 1) value = [value];
            rule.$el.find('.rule-value-container input').each(function (i) {
                $(this).slider('setValue', value[i] || 0);
            });
        },
        valueGetter: function (rule) {
            var value = [];
            rule.$el.find('.rule-value-container input').each(function () {
                value.push($(this).slider('getValue'));
            });
            return rule.operator.nb_inputs == 1 ? value[0] : value;
        }
    };
}

function dateFilter(id, label) {
    return {
        id: id,
        label: label,
        type: 'date',
        operators: ['equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between'],
        validation: { format: 'YYYY/MM/DD' },
        plugin: 'datepicker',
        plugin_config: {
            format: 'yyyy/mm/dd',
            todayBtn: 'linked',
            todayHighlight: true,
            autoclose: true,
            changeMonth: true,
            changeYear: true
        }
    };
}

function textFilter(id, label) {
    return {
        id: id,
        label: label,
        type: 'string',
        operators: ['contains', 'equal', 'not_equal', 'not_contains', 'begins_with', 'ends_with']
    };
}

$('#builder-widgets').queryBuilder({
    plugins: gisQueryBuilderPlugins(),

    filters: gisSortFilters([
        textFilter('ProjectName', 'نام پروژه'),
        textFilter('ProjectCode', 'کد پروژه'),
        selectizeFilter('ProjectType', 'نوع پروژه', TypeValue, 'string', ['equal', 'not_equal', 'contains']),
        selectizeFilter('Region', 'منطقه پروژه', RegionValue, 'string', ['equal', 'not_equal', 'contains']),
        selectizeFilter('Status', 'وضعیت', StatusValue),
        selectizeFilter('ExecutionMethod', 'نحوه اجرا', ExecutionValue),
        selectizeFilter('TahaghoghCategory', 'دسته تحقق', DarsadValue, 'integer'),
        sliderFilter('PlannedProgress', 'پیشرفت برنامه ای'),
        sliderFilter('ActualProgress', 'پیشرفت واقعی'),
        sliderFilter('AchievementPct', 'درصد تحقق'),
        dateFilter('StartDate', 'تاریخ شروع'),
        dateFilter('FinishDate', 'تاریخ پایان'),
        dateFilter('PlannedStart', 'تاریخ شروع برنامه ای'),
        dateFilter('PlannedFinish', 'تاریخ پایان برنامه ای'),
        textFilter('ProjectManager', 'مدیر پروژه'),
        textFilter('ProjectSupervisor', 'ناظر پروژه'),
        textFilter('OrgLevel1', 'سطح 1 سازمان'),
        textFilter('OrgLevel2', 'سطح 2 سازمان')
    ])
});

try {
    var setRulesFromSQL = GetParentSearchOption();
    if (setRulesFromSQL != null) {
        $('#builder-widgets').queryBuilder('setRulesFromSQL', setRulesFromSQL);
    }
} catch (e) {
}

$('#btn-reset').on('click', function () {
    $('#builder-widgets').queryBuilder('reset');
});

$('#btn-set').on('click', function () {
    var setRulesFromSQL = GetParentSearchOption();
    if (setRulesFromSQL != null) {
        $('#builder-widgets').queryBuilder('setRulesFromSQL', setRulesFromSQL);
    }
});

$('#btn-Search').on('click', function () {
    parent.setInformation_Project($('#builder-widgets').queryBuilder('getSQL', false, true), gisDescribeBuilder($('#builder-widgets')));
    parent.ShowAllRoutInMap();
});

function GetParentSearchOption() {
    return parent.GetRulesWidgets_Project();
}
