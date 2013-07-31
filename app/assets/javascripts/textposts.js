function updateCountdown() {
    // 500 is the max message length
    var remaining = 500 - jQuery('#textpost_content').val().length;
    jQuery('.countdown').text(remaining);
}

jQuery(document).ready(function($) {
    updateCountdown();
    $('#textpost_content').change(updateCountdown);
    $('#textpost_content').keyup(updateCountdown);
});