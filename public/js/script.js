var input = document.getElementById("block-new-host-input");
var link = document.getElementById("block-new-host-link");
var blockUrl = "block"

input.addEventListener('input', function()
{
    link.href = blockUrl + "?host=" + input.value;
});