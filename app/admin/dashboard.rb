# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Refunded Amount", class: "admin-dashboard" do
          ul do
            Transaction.joins(:order).where("orders.status"=>"refunded").sum(:total_amount)
          end
        end
      end
      column do
        panel "Total Amount",  class: "admin-dashboard" do
          ul do
            Transaction.sum(:total_amount)
          end
        end
      end
    end
    columns do
      column do
        panel "Products", class: "admin-dashboard" do
          ul do
            Product.count
          end
        end
      end
      column do
        panel "Sellers",  class: "admin-dashboard" do
          User.where(role: "seller").count
        end
      end
    end
    columns do
      column do
        panel "Product Type" do
          pie_chart Product.group(:product_type).count
        end
      end
      column do
        panel "Product Categories" do
          pie_chart Category.all.map{|cat| [cat.categories_type, cat.products.count]}.to_h
        end
      end
    end

    columns do
      column do
        panel "Registered User" do
          line_chart User.group_by_day(:created_at).count
        end
      end
    end

  end 
end
