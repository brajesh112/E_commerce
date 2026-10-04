FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "Test User" }
    phone_number { "9876543210" } # validates length == 10
    role { :buyer }
    password { "password123" }
    password_confirmation { "password123" }

    trait(:admin)  { role { :admin } }
    trait(:seller) { role { :seller } }
  end

  factory :category do
    sequence(:categories_type) { |n| "Category #{n}" }
  end

  factory :sub_category do
    sequence(:name) { |n| "SubCategory #{n}" }
    association :category
  end

  factory :variant do
    sequence(:variant_name) { |n| "Variant #{n}" }
    category_comission { 10 }
    association :sub_category
  end

  factory :product_size do
    size { "M" }
    association :variant
  end

  factory :product do
    sequence(:product_name) { |n| "Product #{n}" }
    stock { 10 }
    price { 100 }
    discount_price { 90 }
    description { "A product" }
    product_type { :national }
    price_id { "price_test_123" }
    association :user
    association :category
    association :variant
    # Views render product.images.first via image_tag; without an attachment
    # the Cloudinary helper raises "Nil location". Attach a real file (test
    # uses the Disk service).
    after(:build) do |product|
      product.images.attach(
        io: File.open(Rails.root.join("app/assets/images/profile.png")),
        filename: "product.png",
        content_type: "image/png"
      )
    end
  end

  factory :product_color do
    color { "red" }
    association :product
  end

  factory :size do
    association :product
    association :product_size
  end

  factory :discount do
    discount_amount { 10 }
    association :product
  end

  factory :offer_type do
    sequence(:name) { |n| "Offer #{n}" }
    discount_percent { "10" }
  end

  factory :cart do
    association :user
  end

  # LineItem maps to the `items` table.
  factory :line_item do
    quantity { 1 } # must be > 0
    association :cart
    association :product
  end

  factory :address do
    house_no { "12A" }
    street { "Main Street" }
    landmark { "Near Park" }
    pin { "110001" }
    country { "VA" } # Vatican: no states/cities, so those validations pass blank
    association :user
  end

  factory :bank_account do
    account_no { "1234567890" }
    ifsc_code { "HDFC0001234" }
    bank { "HDFC" }
    branch_name { "MG Road" }
    city { "Mumbai" }
    association :user
  end

  factory :order do
    payment_method { :cash }
    status { :pending }
    track_id { "TRC123456" }
    description { "Order description" } # views call description.html_safe
    association :user
    association :address

    # Orders index/show render shipment_path(order.shipment); a real order has
    # a shipment. This builds one (with the product+address graph it needs).
    trait :with_shipment do
      after(:create) do |order|
        create(:shipment, order: order)
      end
    end
  end

  factory :order_item do
    quantity { 1 }
    association :order
    association :product
  end

  factory :payment do
    sequence(:payment_id) { |n| "pi_test_#{n}" }
    sequence(:stripe_session_id) { |n| "cs_test_#{n}" }
    gateway { "stripe" }
    amount { 100 }
    status { :success }
    association :order

    trait :pending do
      status { :pending }
      payment_id { nil }
    end

    trait :razorpay do
      gateway { "razorpay" }
      stripe_session_id { nil }
      sequence(:razorpay_payment_link_id) { |n| "plink_test_#{n}" }
    end
  end

  factory :transaction, class: "Transaction" do
    admin_commision { 5 }
    seller_earning { 90 }
    tax { 5 }
    total_amount { 100 }
    quantity { 1 }
    product { "Product name" }
    status { :pending }
    association :user
    association :order
  end

  factory :shipment do
    status { :ordered }
    expected_delivery { 7.days.from_now }
    association :order
    # Shipment#create_tracking_order (after_create) reads
    # order.products.first.user.addresses.first.city, so the order needs a
    # product whose seller has an address. Set it up on the persisted order
    # before the shipment saves.
    after(:build) do |shipment|
      if shipment.order.products.empty?
        product = create(:product)
        # A real city so create_tracking_order builds a valid TrackingOrder
        # (place is required); Vatican addresses have no city.
        create(:address, user: product.user, country: "IN", state: "MH", city: "Mumbai")
        shipment.order.products << product
      end
    end
  end

  factory :tracking_order do
    status { :ordered }
    place { "Mumbai" }
    association :shipment
  end

  factory :notification do
    action { "Something happened" }
    association :user
    association :notificable, factory: :product
  end

  factory :otp do
    onetp { 123456 }
    association :user
  end

  factory :device_token do
    sequence(:token) { |n| "fcm-token-#{n}" }
    platform { "web" }
    association :user
  end

  factory :terms_and_condition do
    terms { "Be nice." }
  end
end
