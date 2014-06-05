Spree::OrdersController.class_eval do
  respond_to :html,:pdf

   def show
    @order = Spree::Order.find_by_number!(params[:id])
    respond_with(@order) do |format|
      format.pdf do
        template = "invoice"
        if @order.payment_state != 'paid'
          flash[:error] = "Payment hasn't been done yet!"
          redirect_to :back
          return true
        end
        if (template == "invoice") && Spree::PrintInvoice::Config.use_sequential_number? && !@order.invoice_number.present?
          @order.invoice_number = Spree::PrintInvoice::Config.increase_invoice_number
          @order.invoice_date = Date.today
          @order.save!
        end
        render :layout => false , :template => "spree/admin/orders/#{template}.pdf.prawn"
      end
      format.html do 
        respond_with @order
      end
    end
  end

end
