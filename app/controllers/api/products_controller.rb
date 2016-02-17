class Api::ProductsController < Api::ApiController

    def index
        @products = Product.all.order :product_id
        respond_to do |format|
            format.json {
                    render :json => @products.to_json(:include => {:documents => {:include => :document_type}})
            }
        end
    end

    def show
        respond_to do |format|
            format.json { render :json => Product.find(params[:id]).to_json(:include => {:documents => {:include => :document_type}}) }
        end
    end

end
