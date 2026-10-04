# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    # ActiveAdmin 4 removed the `columns`/`column` Arbre DSL; lay the dashboard
    # out with Tailwind grid divs instead.
    div class: "grid grid-cols-1 md:grid-cols-2 gap-4" do
      panel "Refunded Amount", class: "admin-dashboard" do
        h2 Transaction.joins(:order).where("orders.status" => "refunded").sum(:total_amount)
      end
      panel "Total Amount", class: "admin-dashboard" do
        h2 Transaction.sum(:total_amount)
      end
    end

    div class: "grid grid-cols-1 md:grid-cols-2 gap-4" do
      panel "Products", class: "admin-dashboard" do
        h2 Product.count
      end
      panel "Sellers", class: "admin-dashboard" do
        h2 User.where(role: "seller").count
      end
    end

    div class: "grid grid-cols-1 md:grid-cols-2 gap-4" do
      panel "Product Type" do
        pie_chart Product.group(:product_type).count
      end
      panel "Product Categories" do
        pie_chart Category.all.map { |cat| [cat.categories_type, cat.products.count] }.to_h
      end
    end

    div class: "grid grid-cols-1 gap-4" do
      panel "Registered User" do
        line_chart User.group_by_day(:created_at).count
      end
    end
  end
end
