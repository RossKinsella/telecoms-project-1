var input = document.getElementById("block-new-host-input");
var link = $("#block-new-host-link");

input.addEventListener('input', function()
{
    link.attr('host', input.value);
});

$(document).ready(function(){
    // Make all links ajax
    $(document).on('click', '.ajax', function(event) {
        event.preventDefault();
        var host = $(this).attr('host');
        var command = $(this).attr('command');
        message = {command:command, host:host};
        ws.send(JSON.stringify(message));
    });

    // WebSocket magic
    ws = new WebSocket("ws://localhost:4020");
    ws.onmessage = function(evt) {
        message = JSON.parse(evt.data);
        if (message['command']) {
            if (message['command'] == 'new_block') {
                var host = message["host"];
                var newRow = "<tr id='block-" + host + "'><td>" + host + "</td><td style='padding-left:50px'><a class ='ajax' href='' host =" + host + " command = 'unblock'>Unblock</a></td></tr>"
                $("#blocked-hosts").append(newRow);
            }
            if (message['command'] == 'removed_block') {
                var encoded_host = message['host'].split('.').join('\\.');
                var rowToRemove = $("#block-" + encoded_host);
                rowToRemove.remove();
            }
        }
    };
    ws.onclose = function() {  };
    ws.onopen = function() {

    };
});