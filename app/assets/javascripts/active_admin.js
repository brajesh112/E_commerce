//= require arctic_admin/base
//= require activeadmin/quill_editor/quill
//= require activeadmin/quill_editor_input
//= require chartkick
//= require Chart.bundle
$(document).ready(function() {
	new SlimSelect({
	  select: '#product_offer_type_ids'
	});

	$("#product_category_id").change(function(){
		var cat = this.value;
		$.ajax({
			type: 'POST',
      url: '/admin/products/add_sub',
      data: {id: cat},
      dataType: 'json',
      async: false,
      success: function(response){       	
				var list = "<option value=''></option>";
				for (var j = 0; j < response.length; j++){
		      list += "<option value='" +response[j][0]+ "'>" +response[j][1]+ "</option>";
				}			
				$("#product_sub_category_id").html(list);
				$("#sub_div").removeClass("d-none")
			}
		})
	});

	$("#product_sub_category_id").change(function(){
		var cat = this.value;
		$.ajax({
			type: 'POST',
      url: '/admin/products/variant',
      data: {id: cat},
      dataType: 'json',
      async: false,
      success: function(response){       	
				var list = "<option value=''></option>";
				for (var j = 0; j < response.length; j++){
		      list += "<option value='" +response[j][0]+ "'>" +response[j][1]+ "</option>";
				}
				$("#product_variant_id").html(list);
				$("#variant_div").removeClass("d-none")
			}
		})
	});
});
