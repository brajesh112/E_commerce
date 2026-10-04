# Prawn is used by OrdersController#order_pdf to render invoices. Require it
# once at boot instead of inside the controller class body.
require "prawn"
