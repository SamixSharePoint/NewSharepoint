/*babania
* JalaliJSCalendar - Jalali Extension for Date Object 
* Copyright (c) 2008 Ali Farhadi (http://farhadi.ir/)
* Released under the terms of the GNU General Public License.
* See the GPL for details (http://www.gnu.org/licenses/gpl.html).
* 
* Based on code from http://farsiweb.info
*/

JalaliDate = {
    g_days_in_month: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
    j_days_in_month: [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29]
};

JalaliDate.jalaliToGregorian = function (j_y, j_m, j_d) {
    j_y = parseInt(j_y);
    j_m = parseInt(j_m);
    j_d = parseInt(j_d);
    var jy = j_y - 979;
    var jm = j_m - 1;
    var jd = j_d - 1;

    var j_day_no = 365 * jy + parseInt(jy / 33) * 8 + parseInt((jy % 33 + 3) / 4);
    for (var i = 0; i < jm; ++i) j_day_no += JalaliDate.j_days_in_month[i];

    j_day_no += jd;

    var g_day_no = j_day_no + 79;

    var gy = 1600 + 400 * parseInt(g_day_no / 146097); /* 146097 = 365*400 + 400/4 - 400/100 + 400/400 */
    g_day_no = g_day_no % 146097;

    var leap = true;
    if (g_day_no >= 36525) /* 36525 = 365*100 + 100/4 */ {
        g_day_no--;
        gy += 100 * parseInt(g_day_no / 36524); /* 36524 = 365*100 + 100/4 - 100/100 */
        g_day_no = g_day_no % 36524;

        if (g_day_no >= 365)
            g_day_no++;
        else
            leap = false;
    }

    gy += 4 * parseInt(g_day_no / 1461); /* 1461 = 365*4 + 4/4 */
    g_day_no %= 1461;

    if (g_day_no >= 366) {
        leap = false;

        g_day_no--;
        gy += parseInt(g_day_no / 365);
        g_day_no = g_day_no % 365;
    }

    for (var i = 0; g_day_no >= JalaliDate.g_days_in_month[i] + (i == 1 && leap) ; i++)
        g_day_no -= JalaliDate.g_days_in_month[i] + (i == 1 && leap);
    var gm = i + 1;
    var gd = g_day_no + 1;

    return [gy, gm, gd];
}

JalaliDate.checkDate = function (j_y, j_m, j_d) {
    return !(j_y < 0 || j_y > 32767 || j_m < 1 || j_m > 12 || j_d < 1 || j_d >
		(JalaliDate.j_days_in_month[j_m - 1] + (j_m == 12 && !((j_y - 979) % 33 % 4))));
}

JalaliDate.gregorianToJalali = function (g_y, g_m, g_d) {
    g_y = parseInt(g_y);
    g_m = parseInt(g_m);
    g_d = parseInt(g_d);
    var gy = g_y - 1600;
    var gm = g_m - 1;
    var gd = g_d - 1;

    var g_day_no = 365 * gy + parseInt((gy + 3) / 4) - parseInt((gy + 99) / 100) + parseInt((gy + 399) / 400);

    for (var i = 0; i < gm; ++i)
        g_day_no += JalaliDate.g_days_in_month[i];
    if (gm > 1 && ((gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0)))
        /* leap and after Feb */
        ++g_day_no;
    g_day_no += gd;

    var j_day_no = g_day_no - 79;

    var j_np = parseInt(j_day_no / 12053);
    j_day_no %= 12053;

    var jy = 979 + 33 * j_np + 4 * parseInt(j_day_no / 1461);

    j_day_no %= 1461;

    if (j_day_no >= 366) {
        jy += parseInt((j_day_no - 1) / 365);
        j_day_no = (j_day_no - 1) % 365;
    }

    for (var i = 0; i < 11 && j_day_no >= JalaliDate.j_days_in_month[i]; ++i) {
        j_day_no -= JalaliDate.j_days_in_month[i];
    }
    var jm = i + 1;
    var jd = j_day_no + 1;


    return [jy, jm, jd];
}

Date.prototype.setJalaliFullYear = function (y, m, d) {
    var gd = this.getDate();
    var gm = this.getMonth();
    var gy = this.getFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    if (y < 100) y += 1300;
    j[0] = y;
    if (m != undefined) {
        if (m > 11) {
            j[0] += Math.floor(m / 12);
            m = m % 12;
        }
        j[1] = m + 1;
    }
    if (d != undefined) j[2] = d;
    var g = JalaliDate.jalaliToGregorian(j[0], j[1], j[2]);
    return this.setFullYear(g[0], g[1] - 1, g[2]);
}

Date.prototype.setJalaliMonth = function (m, d) {
    var gd = this.getDate();
    var gm = this.getMonth();
    var gy = this.getFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    if (m > 11) {
        j[0] += math.floor(m / 12);
        m = m % 12;
    }
    j[1] = m + 1;
    if (d != undefined) j[2] = d;
    var g = JalaliDate.jalaliToGregorian(j[0], j[1], j[2]);
    return this.setFullYear(g[0], g[1] - 1, g[2]);
}

Date.prototype.setJalaliDate = function (d) {
    var gd = this.getDate();
    var gm = this.getMonth();
    var gy = this.getFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    j[2] = d;
    var g = JalaliDate.jalaliToGregorian(j[0], j[1], j[2]);
    return this.setFullYear(g[0], g[1] - 1, g[2]);
}

Date.prototype.getJalaliFullYear = function () {
    var gd = this.getDate();
    var gm = this.getMonth();
    var gy = this.getFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    return j[0];
}

Date.prototype.getJalaliMonth = function () {
    var gd = this.getDate();
    var gm = this.getMonth();
    var gy = this.getFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    return j[1] - 1;
}

Date.prototype.getJalaliDate = function () {
    var gd = this.getDate();
    var gm = this.getMonth();
    var gy = this.getFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    return j[2];
}

Date.prototype.getJalaliDay = function () {
    var day = this.getDay();
    day = (day + 1) % 7;
    return day;
}


/**
* Jalali UTC functions 
*/

Date.prototype.setJalaliUTCFullYear = function (y, m, d) {
    var gd = this.getUTCDate();
    var gm = this.getUTCMonth();
    var gy = this.getUTCFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    if (y < 100) y += 1300;
    j[0] = y;
    if (m != undefined) {
        if (m > 11) {
            j[0] += Math.floor(m / 12);
            m = m % 12;
        }
        j[1] = m + 1;
    }
    if (d != undefined) j[2] = d;
    var g = JalaliDate.jalaliToGregorian(j[0], j[1], j[2]);
    return this.setUTCFullYear(g[0], g[1] - 1, g[2]);
}

Date.prototype.setJalaliUTCMonth = function (m, d) {
    var gd = this.getUTCDate();
    var gm = this.getUTCMonth();
    var gy = this.getUTCFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    if (m > 11) {
        j[0] += math.floor(m / 12);
        m = m % 12;
    }
    j[1] = m + 1;
    if (d != undefined) j[2] = d;
    var g = JalaliDate.jalaliToGregorian(j[0], j[1], j[2]);
    return this.setUTCFullYear(g[0], g[1] - 1, g[2]);
}

Date.prototype.setJalaliUTCDate = function (d) {
    var gd = this.getUTCDate();
    var gm = this.getUTCMonth();
    var gy = this.getUTCFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    j[2] = d;
    var g = JalaliDate.jalaliToGregorian(j[0], j[1], j[2]);
    return this.setUTCFullYear(g[0], g[1] - 1, g[2]);
}

Date.prototype.getJalaliUTCFullYear = function () {
    var gd = this.getUTCDate();
    var gm = this.getUTCMonth();
    var gy = this.getUTCFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    return j[0];
}

Date.prototype.getJalaliUTCMonth = function () {
    var gd = this.getUTCDate();
    var gm = this.getUTCMonth();
    var gy = this.getUTCFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    return j[1] - 1;
}

Date.prototype.getJalaliUTCDate = function () {
    var gd = this.getUTCDate();
    var gm = this.getUTCMonth();
    var gy = this.getUTCFullYear();
    var j = JalaliDate.gregorianToJalali(gy, gm + 1, gd);
    return j[2];
}

Date.prototype.getJalaliUTCDay = function () {
    var day = this.getUTCDay();
    day = (day + 1) % 7;
    return day;
}



function ConvertJDateObjToG(aDateStr) {
    var parts = aDateStr.split("/");
    if (parts[0].length != 4 || parts[1].length != 2 || parts[2].length != 2) return aDateStr;
    if (parseInt(parts[0] * 1) > 1900) return aDateStr;
    return JTG(parts[0], parts[1], parts[2], 'a');
}



function ConvertGDateObjToJ(aDateStr) {
    try {
        aDateStr = aDateStr.split(" ")[0]; //For hide Date From Time
    } catch (e) {

    }

    var ocd = new Date(aDateStr);
    if (!ocd.getFullYear()) return aDateStr;
    //alert(ocd.getMonth());
    var jd = GTJ(ocd.getFullYear(), (ocd.getMonth() + 1), ocd.getDate(), 'a');
    return jd;
}

//void jalali_to_gregorian(
function JTG(
	j_y,
	j_m,
	j_d,
	choice) {
    var g_days_in_month = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    var j_days_in_month = new Array(31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29);
    var j_month_name = new Array("", "Farvardin", "Ordibehesht", "Khordad", "Tir",
						  "Mordad", "Shahrivar", "Mehr", "Aban", "Azar",
						  "Dey", "Bahman", "Esfand");

    var gy, gm, gd;
    var jy, jm, jd;
    var g_day_no, j_day_no;
    var leap;

    var i;

    jy = j_y - 979;
    jm = j_m - 1;
    jd = j_d - 1;

    j_day_no = 365 * jy + Math.floor(jy / 33) * 8 + Math.floor((jy % 33 + 3) / 4);
    for (i = 0; i < jm; ++i)
        j_day_no += j_days_in_month[i];

    j_day_no += jd;

    g_day_no = j_day_no + 79;

    gy = 1600 + 400 * Math.floor((g_day_no) / (146097)); /* 146097 = 365*400 + 400/4 - 400/100 + 400/400 */
    g_day_no = g_day_no % 146097;

    leap = 1;
    if (g_day_no >= 36525) /* 36525 = 365*100 + 100/4 */ {
        g_day_no--;
        gy += 100 * Math.floor((g_day_no) / (36524)); /* 36524 = 365*100 + 100/4 - 100/100 */
        g_day_no = g_day_no % 36524;

        if (g_day_no >= 365)
            g_day_no++;
        else
            leap = 0;
    }

    gy += 4 * Math.floor((g_day_no) / (1461)); /* 1461 = 365*4 + 4/4 */
    g_day_no %= 1461;

    if (g_day_no >= 366) {
        leap = 0;

        g_day_no--;
        gy += Math.floor((g_day_no) / (365));
        g_day_no = g_day_no % 365;
    }

    for (i = 0; g_day_no >= g_days_in_month[i] + (i == 1 && leap) ; i++)
        g_day_no -= g_days_in_month[i] + (i == 1 && leap);
    gm = i + 1;
    gd = g_day_no + 1;

    var strgm = new String(gm);
    var strgd = new String(gd);

    if (gm < 10)
        strgm = "0" + gm;
    if (gd < 10)
        strgd = "0" + gd;

    if (choice == 'y' || choice == 'Y')
        return String(gy);
    else if (choice == 'm' || choice == 'M')
        return strgm;
    else if (choice == 'd' || choice == 'D')
        return strgd;
    else
        return String(gy) + ' ' + strgm + ' ' + strgd;

}


//function gregorian_to_jalali
function GTJ(
	g_y,
	g_m,
	g_d,
	choice
	) {
    var g_days_in_month = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
    var j_days_in_month = new Array(31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29);
    var j_month_name = new Array("", "Farvardin", "Ordibehesht", "Khordad", "Tir",
						  "Mordad", "Shahrivar", "Mehr", "Aban", "Azar",
						  "Dey", "Bahman", "Esfand");

    var gy, gm, gd;
    var jy, jm, jd;
    var g_day_no, j_day_no;
    var j_np;

    var i;
    gy = g_y - 1600;
    gm = g_m - 1;
    gd = g_d - 1;

    g_day_no = 365 * gy + Math.floor((gy + 3) / 4) - Math.floor((gy + 99) / 100) + Math.floor((gy + 399) / 400);
    for (i = 0; i < gm; ++i)
        g_day_no += g_days_in_month[i];
    if (gm > 1 && ((gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0)))
        /* leap and after Feb */
        ++g_day_no;
    g_day_no += gd;

    j_day_no = g_day_no - 79;

    j_np = Math.floor(j_day_no / 12053);
    j_day_no %= 12053;

    jy = 979 + 33 * j_np + 4 * Math.floor((j_day_no / 1461));
    j_day_no %= 1461;

    if (j_day_no >= 366) {
        jy += Math.floor((j_day_no - 1) / 365);
        j_day_no = (j_day_no - 1) % 365;
    }

    for (i = 0; i < 11 && j_day_no >= j_days_in_month[i]; ++i) {
        j_day_no -= j_days_in_month[i];
    }
    jm = i + 1;
    jd = j_day_no + 1;

    var strjm = new String(jm);
    var strjd = new String(jd);

    if (jm < 10)
        strjm = "0" + jm;
    if (jd < 10)
        strjd = "0" + jd;

    if (choice == 'y' || choice == 'Y')
        return String(jy);
    else if (choice == 'm' || choice == 'M')
        return strjm;
    else if (choice == 'd' || choice == 'D')
        return strjd;
    else
        return String(jy) + '/' + strjm + '/' + strjd; 

}
