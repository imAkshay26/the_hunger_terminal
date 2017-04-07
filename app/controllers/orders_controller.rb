class OrdersController < ApplicationController

  load_and_authorize_resource  param_method: :order_params
 
  def order_history
    @orders = current_user.orders.where(date: params[:from]..params[:to]).order(date: :desc)
  end

  def load_terminal
    @terminals = Terminal.where(active: true, company: current_user.company)
  end

  def new 
    @terminal = Terminal.find(params[:terminal_id])
    @order = @terminal.orders.new
    # @terminal_id = params[:terminal_id]
    @menu_items = MenuItem.where(terminal_id: params[:terminal_id]).where("active_days @> ARRAY[?]::varchar[]",[Time.zone.now.wday.to_s]).where(available: true)
  end

  def show
     @order = Order.find(params[:id])
  end


  def edit
    @terminal = Terminal.find(params[:terminal_id])
    @order = @terminal.orders.find(params[:id])
    @terminal_id = params[:terminal_id]
    @menu_items = MenuItem.where(terminal_id: params[:terminal_id]).where("active_days @> ARRAY[?]::varchar[]",[Time.zone.now.wday.to_s]).where(available: true)
  end

  def update
    @order = Order.find(params[:id])
    
    # @order.order_details = OrderDetail.where(params[:order_id])
    # @order.order_details.clear
    if @order.update_attributes(order_params) 
      redirect_to terminal_order_path(params[:terminal_id],@order)
    else
      render 'edit'
    end
  end


  def create
    @terminal = Terminal.find(params[:terminal_id])
    @order = @terminal.orders.new(order_params)
    load_order_detail
    if @order.save
      redirect_to terminal_order_path(params[:terminal_id],@order)
    else
      if @order.errors.full_messages.include?("User has already been taken")
        flash[:error] = "Only one order is allowed per day"
      else
        flash[:error] = @order.errors.full_messages.join(",")
      end 
      redirect_to vendors_path
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to vendors_path
  end  

  private

    def order_params
      params.require(:order).permit(
        :total_cost,:terminal_id,:id, order_details_attributes:[:menu_item_id, :quantity, :id]
      ).merge(user_id: current_user.id)
    end

    def load_order_detail
      @order.date = Date.today
      @order.company_id = current_user.company.id
    end

end
