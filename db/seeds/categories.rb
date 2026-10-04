# E-commerce categories and their sub-categories.
# Idempotent: find_or_create_by so re-running `db:seed` never duplicates rows.

categories = {
  "Electronics"        => ["Mobiles", "Laptops", "Headphones", "Cameras", "Smart Watches", "Televisions"],
  "Fashion"            => ["Men's Clothing", "Women's Clothing", "Footwear", "Watches", "Bags & Luggage", "Jewellery"],
  "Home & Kitchen"     => ["Furniture", "Kitchen Appliances", "Cookware", "Home Decor", "Bedding", "Lighting"],
  "Beauty & Personal Care" => ["Skincare", "Makeup", "Hair Care", "Fragrances", "Grooming"],
  "Sports & Outdoors"  => ["Fitness Equipment", "Cycling", "Camping & Hiking", "Sportswear", "Team Sports"],
  "Books & Stationery" => ["Fiction", "Non-Fiction", "Academic", "Children's Books", "Office Supplies"],
  "Toys & Baby"        => ["Toys & Games", "Baby Care", "Kids' Clothing", "School Supplies"],
  "Grocery & Gourmet"  => ["Beverages", "Snacks", "Staples", "Organic Foods", "Household Supplies"],
}

categories.each do |category_name, sub_category_names|
  category = Category.find_or_create_by!(categories_type: category_name)
  sub_category_names.each do |sub_name|
    SubCategory.find_or_create_by!(name: sub_name, category: category)
  end
end

puts "Seeded #{Category.count} categories and #{SubCategory.count} sub-categories."
