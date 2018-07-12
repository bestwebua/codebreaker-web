(function() {
  var div, i, type = "";
  var button = "";
  div = document.querySelectorAll("#guess_marker")[0];

  for (i = 0; i < div.innerText.length; i++) {
    current_char = div.innerText[i]

    switch (current_char) {
      case '+':
        type = 'btn-success';
        break;
      case '-':
        type = 'btn-primary';
        break;
      default:
        type = 'btn-danger';
    }

    button += `<button type=button class='btn ${type} marks'>`;
    button += current_char;
    button += "</button>";

  }

  div.innerHTML = button;
  
})();
