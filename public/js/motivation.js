function hideAlert(id) {
  var text = $('#'+id+' .message').text();
  if(text.length <= 12)
    $('#'+id).hide();
}