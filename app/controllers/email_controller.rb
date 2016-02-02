class EmailController < ApplicationController

    def new
        @product = Product.find(params[:product_id])
        render 'new'
    end

    def create
        @product = Product.find(params[:product_id])
        from = current_user.email
        to = params[:email][:to]
        subject = params[:email][:subject]
        body = params[:email][:body]
        unless params[:product_id].nil?
            p = @product
            mail = AlchemyMailer.send_with_attachment(from, to, subject, body, p.sds, p.absolute_documents_path.join(p.sds))
        else
            mail = AlchemyMailer.send_full_email(from, to, subject, body)
        end
        mail.deliver!

        flash.now[:notice] = "Email sent successfully!"
        render :new
    end

end
