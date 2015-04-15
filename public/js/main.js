;(function(){
    $("#name-input-groups").on("click", 'button', function(){
        var role_span = $(this).find("span");
        console.log( role_span.hasClass("glyphicon-plus") );
        if (role_span.hasClass("glyphicon-plus")) {
            $("#name-input-groups").append( [
                '<div class="input-group" btn-role="add">',
                    '<span class="input-group-btn">',
                        '<button class="btn btn-default" type="button">',
                            '<span class="glyphicon glyphicon-plus" />',
                        '</button>',
                    '</span>',
                    '<input class="form-control" type="text" name="name" />',
                '</div>',
            ].join(''));
            role_span.removeClass("glyphicon-plus");
            role_span.addClass("glyphicon-minus");
        } else {
            $(this).parent().parent().remove();
        }
    });
})(jQuery)
