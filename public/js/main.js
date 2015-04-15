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

    $('.checkbox_parent').on('click', function(){
        var children = $('.checkbox_child[data-page="'+ $(this).attr('data-page')  +'"]'),
            isChecked = $(this).prop('checked');
        $(children).prop('checked', isChecked);
    });

    $('tbody').on('click', 'tr', function(event){
        if ($(event.target).hasClass('checkbox_child')) return;

        var checkbox = $(this).find(':checkbox'),
            isChecked = checkbox.prop('checked');
        checkbox.prop('checked', !isChecked );
    });

    $('#use-button').on('click', function(){
        var checked_card = $(document).find(':checked');
        var uuids = [];
        checked_card.each( function(){
            if ($(this).hasClass('checkbox_parent')) return;
            var tr = $(this).parent().parent();
            uuids.push(tr.attr('data-uuid'));
        });

        var data = { uuids: uuids };
        $.ajax({
            type: "DELETE",
            url: "/delete",
            data: data,
            success: function(html){
                var href = window.location.href.split('/');
                window.location.href = href[0] + '//' + href[2];
            }
        });
        return false;
    });
})(jQuery)
