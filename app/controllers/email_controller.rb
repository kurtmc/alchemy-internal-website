class EmailController < ApplicationController

    def new
        @to = params[:to]
        @subject = params[:subject]
        @body = params[:body]
        @attachment_name = params[:attachment_name]
        @attachment_path = params[:attachment_path]
        render 'new'
    end

    def create
        from = current_user.email
        to = params[:email][:to]
        subject = params[:email][:subject]
        body = params[:email][:body]
        unless params[:attachment_path].blank?
            mail = AlchemyMailer.send_with_attachment(from, to, subject, body, params[:attachment_name], params[:attachment_path])
        else
            mail = AlchemyMailer.send_full_email(from, to, subject, body)
        end
        mail.deliver!

        flash.now[:notice] = "Email sent successfully!"
        render :new
    end

end
