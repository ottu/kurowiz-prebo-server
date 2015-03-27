;(function(){
    $('#test-hook').on('click', function() {
        $('#test').toggleClass("open");
    });
    $("#menu-button").click(function(){
        $("#bs-navbar-collapse").toggleClass("in");
    });
})(jQuery)


