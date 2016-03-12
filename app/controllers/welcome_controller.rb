class WelcomeController < ApplicationController
    def index
        @notice = get_notice
    end

    def update
        puts "UPDATE!!!!!!!!"
        puts params.inspect

        @notice = get_notice
        @notice.content = params[:notice_board][:body]
        @notice.save

        render action: 'index'
    end

    private

    def get_notice
        if NoticeBoard.all.size == 0
            notice = NoticeBoard.new
        else
            notice = NoticeBoard.all[0]
        end
        return notice
    end

end
