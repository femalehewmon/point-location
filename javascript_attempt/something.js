$(tri.element).on("mouseover", function(){
    var friend = $(this).id;
    $(this).css({
        "fill": "blue",
        "fill-opacity": "1"
    });
});

// You're inside your loop, and you're assuming the current text you'd like to render is called 'currentText'

$("#textbox").html()