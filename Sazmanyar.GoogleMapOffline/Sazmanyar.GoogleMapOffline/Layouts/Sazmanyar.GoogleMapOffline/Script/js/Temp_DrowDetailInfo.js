function DrowDetailInfo_strcontent(bindings, CabDeleteMarker) {

    // Creating a Dispay Content 
    var strcontent = '<div style="padding-bottom: 20px; padding-left: 20px; padding-right: 20px;"  id="info">';
    strcontent = strcontent + ' <table> '

    strcontent = strcontent + '<tr> <td> '
    strcontent = strcontent + '<p style="font-weight: bold;" > عنوان: </p>';
    strcontent = strcontent + ' </td> <td> ';
    strcontent = strcontent + bindings._x0646__x0627__x0645__x0020__x06;
    strcontent = strcontent + ' </td> <tr> ';

    strcontent = strcontent + '<tr> <td> '
    strcontent = strcontent + '<p style="font-weight: bold;" > تعداد خود پرداز: </p>';
    strcontent = strcontent + ' </td> <td> ';
    strcontent = strcontent + bindings._x062a__x0639__x062f__x0627__x06;
    strcontent = strcontent + ' </td> <tr> ';

    strcontent = strcontent + '<tr> <td> '
    strcontent = strcontent + '<p style="font-weight: bold;" > استان شعبه: </p>';
    strcontent = strcontent + ' </td> <td> ';
    strcontent = strcontent + bindings._x0627__x0633__x062a__x0627__x06;
    strcontent = strcontent + ' </td> <tr> ';

    strcontent = strcontent + '<tr> <td> '
    strcontent = strcontent + '<p style="font-weight: bold;" > شهر شعبه: </p>';
    strcontent = strcontent + ' </td> <td> ';
    strcontent = strcontent + bindings._x0634__x0647__x0631_;
    strcontent = strcontent + ' </td> <tr> ';


    strcontent = strcontent + '<tr> <td> '
    strcontent = strcontent + '<p style="font-weight: bold;" > تلفن شعبه: </p>';
    strcontent = strcontent + ' </td> <td> ';
    strcontent = strcontent + bindings._x062a__x0644__x0641__x0646_;
    strcontent = strcontent + ' </td> <tr> ';


    strcontent = strcontent + '<tr> <td> '
    strcontent = strcontent + '<p style="font-weight: bold;" > فکس شعبه: </p>';
    strcontent = strcontent + ' </td> <td> ';
    strcontent = strcontent + bindings._x0641__x06a9__x0633_;
    strcontent = strcontent + ' </td> <tr> ';


    strcontent = strcontent + '<tr> <td> '
    strcontent = strcontent + '<p style="font-weight: bold;" > نشانی شعبه: </p>';
    strcontent = strcontent + ' </td> <td> ';
    strcontent = strcontent + bindings._x0646__x0634__x0627__x0646__x06;
    strcontent = strcontent + ' </td> <tr> ';



    strcontent = strcontent + '<tr> <td> '
    strcontent = strcontent + '<p  style="font-weight: bold;" ><a href="/Lists/Google%20Map%20List/DispForm.aspx?ID=' + bindings.ID + '"  target= "_blank"   >نمایش جزئیات</a></p>';
    strcontent = strcontent + ' </td> <td> ';
    if (CabDeleteMarker == true) {
        strcontent = strcontent + '<p  style="font-weight: bold;" ><a href="#" onclick=\'Delete_SelectedMarkListItems(' + bindings.ID + ')\'  height="40px" width="40px"   >حذف این نشان</a></p>';
    }
    strcontent = strcontent + ' </td> <tr> ';

    strcontent = strcontent + ' </table> '

    strcontent = strcontent + '</div>';

    return strcontent;
} 