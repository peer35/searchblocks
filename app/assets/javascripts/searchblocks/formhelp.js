addBlock = function () {
    $("#blocks_text").append($("#new_block_form").html())
};

removeBlock = function (element) {
    return element.parent().remove();
};
