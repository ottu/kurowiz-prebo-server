;(function(){
    $('#test-hook').on('click', function() {
        console.log("test");
        $('#test').toggleClass("open");
    });
    $("#menu-button").click(function(){
        $("#bs-navbar-collapse").toggleClass("in");
    });
    $("label[id^=element-button]").on('click', function(){
        var id = $(this).attr("id");
        var cls = "";
        switch (id) {
            case "element-button-fire": { cls = "btn-danger" } break;
            case "element-button-water": { cls = "btn-info" } break;
            case "element-button-thunder": { cls = "btn-warning" } break;
            case "element-button-none": { cls = "btn-success" } break;
        }
        $(this).toggleClass("btn-default");
        $(this).toggleClass(cls);
    });
    $("#name-input-groups").on("click", 'button', function(){
        var role_span = $(this).find("span");
        console.log( role_span.hasClass("glyphicon-plus") );
        if (role_span.hasClass("glyphicon-plus")) {
            $("#name-input-groups").append( [
                '<tr btn-role="add">',
                    '<td>',
                        '<div class="input-group" id="name-input-group">',
                            '<span class="input-group-btn">',
                                '<button class="btn btn-default" type="button">',
                                    '<span class="glyphicon glyphicon-plus" />',
                                '</button>',
                            '</span>',
                            '<input class="form-control" type="text" />',
                        '</div>',
                    '</td>',
                '</tr>'
            ].join(''));
            role_span.removeClass("glyphicon-plus");
            role_span.addClass("glyphicon-minus");
        } else {
            $(this).parent().parent().parent().parent().remove();
        }
    });
})(jQuery)


