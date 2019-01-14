/**
 * Created by peter on 22-6-2017.
 */

$(document).ready(ready)
$(document).on('turbolinks:load', ready)

function ready() {
    replaceSemiColons();
    replaceNewline();
}

function replaceNewline() {
    $('#document dd.blacklight-notes_s').each(function (index, dd) {
        if (!$(dd).hasClass('coded')) {
            var desctmp = $(dd).html();
            lines = desctmp.split(/\r\n|\r|\n/g);

            //desc=desctmp.replace('\n','<br>');
            desc = lines.join('<br>');
            $(dd).addClass('coded')
            $(dd).html(desc);
        }
    });
}

function replaceSemiColons() {
    $('#document dd.blacklight-searchblock_s').each(function (index, dd) {
        if (!$(dd).hasClass('coded')) {
            var desctmp = $(dd).html();
            var arr = desctmp.split(';;');
            var desc = ''
            for (var i = 0; i < arr.length; i++) {

                var blocktmp = arr[i];
                var arr2 = blocktmp.split(': ', 2);
                if (arr2.length > 1) {
                    block = arr2[0] + ':<br><pre><code>' + arr2[1] + '</code></pre>';
                } else {
                    block = '<pre><code>' + blocktmp + '</code></pre>';
                }
                desc = desc + block;
            }
            $(dd).addClass('coded')
            $(dd).html(desc);
        }
    });
    /*
        $('#documents dd').each(function (index, dd) {
            // need some kind of on ajax
            var desctmp = $(dd).html();
            desctmp = desctmp.replace(/;/g, '<br>');
            $(dd).html(desctmp);
        });
        */
}