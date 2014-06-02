$(document).ready(function() {	
	$('.expand').click(function(){
		$('#' + $(this).attr('id') + '-content').is(':visible')?$(this).children('.sign').html('+'):$(this).children('.sign').html('-');
		$('#' + $(this).attr('id') + '-content').toggle('slow');
	});
	
	$i = 0;
	$('.tab').each(function() {
		$(this).css('left', function() {
			return $i * 100 + 20;
		});
		$i++;
	});
	
	$('.tab').not('.link').click(function() {
		$('.tab').not(this).removeClass('current');
		$(this).addClass('current');
		$('.content').not('#' + $(this).attr('id') + '-content').hide();
		$('#' + $(this).attr('id') + '-content').show();
	});
});
	