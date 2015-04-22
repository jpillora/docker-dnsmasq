/* global $,ace */

var editor = ace.edit("editor");
editor.setShowPrintMargin(false);
editor.$blockScrolling = Infinity;
editor.setTheme("ace/theme/github");
editor.getSession().setMode("ace/mode/ini");


function showhide(elem) {
  elem.slideDown(500);
  setTimeout(function() {
    // elem.fadeOut(300);
    elem.slideUp(500);
  }, 3000);
}

function err(xhr) {
  $("#errmsg").text(xhr.responseText);
  showhide($("#err"));
}

//load initial state
$.get("/configure").then(function(cfg) {
  console.log("initialised");
  editor.setValue(cfg);
}).fail(err);

//handle save click
var save = $("button");
var loading = false;
save.on("click", function() {
  if(loading) return;
  loading = true;
  save.addClass("loading");
  var cfg = editor.getValue();
  //ajax
  $.ajax({method: "POST", url:"/configure", processData:false, data:cfg}).then(function() {
    showhide($("#success"));
  }).fail(err).always(function() {
    save.removeClass("loading");
    loading = false;
    console.log("always");
  });
});
