;(function(){
    $('#test-hook').on('click', function() {
        console.log("test");
        $('#test').toggleClass("open");
    });
    $("#menu-button").click(function(){
        $("#bs-navbar-collapse").toggleClass("in");
    });
    $("label[id^=element-button] input").on('click', function(){
        var label = $(this).parent();
        var id = label.attr("id");
        var cls = "";
        switch (id) {
            case "element-button-fire": { cls = "btn-danger" } break;
            case "element-button-water": { cls = "btn-info" } break;
            case "element-button-thunder": { cls = "btn-warning" } break;
            case "element-button-none": { cls = "btn-success" } break;
        }
        label.toggleClass("btn-default");
        label.toggleClass(cls);
    });
    $("#name-input-groups").on("click", 'button', function(){
        var role_span = $(this).find("span");
        console.log( role_span.hasClass("glyphicon-plus") );
        if (role_span.hasClass("glyphicon-plus")) {
            $("#name-input-groups").append( [
                '<div class="input-group" id="name-input-group" btn-role="add">',
                    '<span class="input-group-btn">',
                        '<button class="btn btn-default" type="button">',
                            '<span class="glyphicon glyphicon-plus" />',
                        '</button>',
                    '</span>',
                    '<input class="form-control" type="text" />',
                '</div>',
            ].join(''));
            role_span.removeClass("glyphicon-plus");
            role_span.addClass("glyphicon-minus");
        } else {
            $(this).parent().parent().remove();
        }
    });
})(jQuery)


