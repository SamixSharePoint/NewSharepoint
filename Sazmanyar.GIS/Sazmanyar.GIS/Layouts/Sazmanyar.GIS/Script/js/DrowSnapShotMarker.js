function createSnapShotMarker_strcontent(bindings) {

    // Creating a Dispay Content

    var strcontent = '<div dir="rtl" style="text-align: center;">';

    if ((typeof (bindings.FinalFTPImg) != 'undefined') && (bindings.FinalFTPImg != "")) {
        strcontent = strcontent + '<img  width="200px" height="100px"  src="' + bindings.FinalFTPImg + '" alt="" />';
    }
    strcontent = strcontent + ' <p  >' + bindings.Title + '</p>';
    strcontent = strcontent + '</div>'

    return strcontent;
}  
