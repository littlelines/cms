require_dependency "push_type/admin_controller"

module PushType
  class Admin::InquiriesController < AdminController

    def index
      @inquiries = inquiry_scope.order(created_at: :desc).page(params[:page]).per(30)
    end

    def show
      @inquiry = inquiry_scope.find(params[:id])
    end

    private

    def inquiry_scope
      PushType::Inquiry
    end

    def initial_breadcrumb
      breadcrumbs.add 'Inquiries', push_type_admin.inquiries_path
    end

    def inquiry_params
      fields = [:name, :email] + @inquiry.fields.keys
      params.fetch(:inquiry, {}).permit(*fields)
    end

  end
end
