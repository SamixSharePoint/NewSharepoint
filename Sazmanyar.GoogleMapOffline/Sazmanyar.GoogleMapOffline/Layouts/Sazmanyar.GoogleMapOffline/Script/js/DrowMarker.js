function createMarker_strcontent(bindings, CabDeleteMarker) {

    // Creating a Dispay Content 
    var strcontent = '<div id="info" class="gmo-iw">';
    //    if (bindings.LogoUrl != "") {
    //        strcontent = strcontent + '<img src="' + bindings.LogoUrl + '" alt="" />';
    //    }
    strcontent = strcontent + '<h2>' + bindings.Title + '</h2>' +
                                         '<p>' + bindings.Description + '</p>';

    if (CabDeleteMarker == true) {
        strcontent = strcontent + '<p><a href="#" onclick=\'Delete_SelectedMarkListItems(' + bindings.ID + ')\'  height="40px" width="40px"   >حذف این نشان</a></p>';
    }

    strcontent = strcontent + '<p  style="font-weight: bold;" ><a href="/Lists/Google%20Map%20List/DispForm.aspx?ID=' + bindings.ID + '"  target= "_blank"   >نمایش جزئیات</a></p>';

    strcontent = strcontent + '</div>';

    return strcontent;
}  
