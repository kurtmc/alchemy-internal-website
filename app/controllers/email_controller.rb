class EmailController < ApplicationController

    def new
        render 'new'
    end

    def create
        from = current_user.email
        to = params[:email][:to]
        subject = params[:email][:subject]
        body = params[:email][:body]
        mail = AlchemyMailer.send_full_email(from, to, subject, body)
        mail.deliver!

        render 'new'
    end

end
