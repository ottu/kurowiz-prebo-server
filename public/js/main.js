;(function(){
    // global init
})(jQuery)


$(document).ready(function(){
    $("#name-input-groups").on("click", 'button', function(){
        var role_span = $(this).find("span");
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
        var checked_card = $('#main-list').find(':checked');
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

    $('#enlist-button').on('click', function(){
        console.log('enlist button clicked!');

        var element_dic = {
            'fire': '火',
            'water': '水',
            'thunder': '雷',
            'none': '無'
        };

        var category_dic = {
            'spirit': '精',
            'material': '素',
            'ether': 'エ',
            'mana': 'マ',
            'item': 'ア',
            'crystal': 'ク',
            'gold': 'ゴ',
            'mate': 'メ'
        };

        var name = $('#modal-name-input').val().trim();
        var main = $('#modal-main-element-radio').find('input:checked').val();
        var sub = $('#modal-sub-element-radio').find('input:checked').val();
        var category = $('#modal-category-radio').find('input:checked').val().trim();
        var rank = $('#modal-rank-radio').find('input:checked').val().trim();
        var option = $('#modal-option-input').val();

        if (name == "") return false;
        if (main == "") return false;
        if (category == "") return false;
        if (rank == "") return false

        var element = main;
        var show_element = element_dic[main];
        if (sub != undefined) {
            element += '/' + sub;
            show_element += '/' +element_dic[sub];
        }
        var show_category = category_dic[category];

        var json = {
            'name': name,
            'element': element,
            'category': category,
            'rank': rank,
            'option': option
        }

        var tbody = $('#news-tbody');
        tbody.append([
            '<tr>',
                '<th class="w10">',
                    '<button class="btn btn-default btn-xs" type="button">',
                        '<span class="glyphicon glyphicon-minus" />',
                    '</button>',
                '</th>',
                '<th data-name="' + name + '">' + name + '</th>',
                '<th class="w15" data-element="' + element + '">' + show_element+ '</th>',
                '<th class="w10" data-category="' + category + '">' + show_category + '</th>',
                '<th class="w10" data-rank="' + rank + '">' + rank + '</th>',
                '<th class="w15" data-option="' + option + '">' + option + '</th>',
            '</tr>'
        ].join(''));
    });

    $('#modal-sub-element-button').on('click', function(){
        var radio = $('#modal-sub-element-radio');
        radio.find('label').removeClass('active');
        radio.find('input').attr('checked', false);
    });

    $('#add-button').on('click', function(){
        console.log('add button clicked!');

        var news = [];
        var trs = $('#news-tbody').find('tr');
        $.each(trs, function(i, tr) {
            var tr = $(tr);
            var name = tr.children('th[data-name]').attr('data-name');
            var element = tr.children('th[data-element]').attr('data-element');
            var category = tr.children('th[data-category]').attr('data-category');
            var rank = tr.children('th[data-rank]').attr('data-rank');
            var option = tr.children('th[data-option]').attr('data-option');

            var csv =  name + ',' + element + ',' + category + ',' + rank + ',' + option;
            news.push(csv);
        })

        var data = news.join('\n');
        $.ajax({
            type: "POST",
            url: "/add",
            data: { "news": data },
            success: function(html){
                var href = window.location.href.split('/');
                window.location.href = href[0] + '//' + href[2];
            }
        });
        return false;

    });

    $('#news-tbody').on('click', 'button', function(){
        $(this).parent().parent().remove();
    });


})
