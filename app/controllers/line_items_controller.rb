class LineItemsController < ApplicationController
  before_action :_set_line_item, only: [:update, :destroy]
  include CurrentCart
  before_action :_set_cart, only: [:create, :update_multiple]
  before_action :_ensure_cart_isnt_empty, only: :update_multiple


  def create
    product = Product.find(params[:line_item][:product_id])
    @line_item = @cart.add_product(_permitted_line_item_params)
    respond_to do |format|
      if @line_item.save
        format.html { redirect_to product_path(product) }
        format.json { render :show, status: :created, location: @line_item }
      else
        format.html { render :new }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end


  def update_multiple
    LineItem.find(params[:line_items_ids]).zip(params[:line_items_quantities]).each do |line_item, quantity|
      line_item.update quantity: quantity
    end
    redirect_to new_order_path
  end

  def destroy
    @line_item.destroy
    respond_to do |format|
      format.html { redirect_to cart_path }
      format.json { head :no_content }
    end
  end

  private
    def _permitted_line_item_params
      params.require(:line_item).permit(:product_id, :quantity, :size )
    end

    def _set_line_item
      @line_item = LineItem.find(params[:id])
    end

end
