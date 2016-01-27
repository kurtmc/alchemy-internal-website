require 'utils/pdf_modifier'

class PdfModifyController < ApplicationController

    def new
    end

    def create
        if params[:pdf].nil?
            render 'new'
            return
        end
        pdf_files = params[:pdf][:pdf_files]
        landscape = params[:pdf][:landscape] == '1'
        template = get_template
        PdfModifier.modify_pdf(pdf_files, template, landscape, self)
    end

    def get_template
        raise NotImplementedError.new "get_template"
    end

end
