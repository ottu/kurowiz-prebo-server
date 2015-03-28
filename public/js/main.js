;(function(){
    $('#test-hook').on('click', function() {
        console.log("test");
        $('#test').toggleClass("open");
    });
    $("#menu-button").click(function(){
        $("#bs-navbar-collapse").toggleClass("in");
    });
    $("label[id^=element-button]").on('click', function(){
        var cls = "";
        switch ($(this).text().trim()) {
            case "火": { cls = "btn-danger" } break;
            case "水": { cls = "btn-info" } break;
            case "雷": { cls = "btn-warning" } break;
        }
        $(this).toggleClass("btn-default");
        $(this).toggleClass(cls);
    });
})(jQuery)


