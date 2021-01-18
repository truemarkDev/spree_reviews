module Spree
  module Api
    module V2
      module Storefront
        class ReviewsController < ::Spree::Api::V2::ResourceController
          include Spree::Api::V2::CollectionOptionsHelpers

          before_action :load_product, only: [:index, :create, :update]
          before_action :load_review, only: [:update, :destroy]

          def index
            render_serialized_payload {serialize_collection(paginated_collection)}
          end

          def show
            render_serialized_payload {serialize_resource(resource)}
          end

          def create
            # TODO move to service
            # result = create_service.call(user: spree_current_user, review_params: review_params, product: @product, ip_address: request.remote_ip)
            params[:review][:rating].sub!(/\s*[^0-9]*\z/, '') unless params[:review][:rating].blank?

            @review = Spree::Review.new(review_params)
            @review.product = @product
            @review.user = spree_current_user if spree_user_signed_in?
            @review.ip_address = request.remote_ip
            @review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]

            # TODO: @prakash fix permission
            # authorize! :create, @review

            render_result(@review)
          end

          def update
            params[:review][:rating].sub!(/\s*[^0-9]*\z/, '') unless params[:review][:rating].blank?

            # TODO: fix permission
            # authorixe! :update, @review
            @review.ip_address = request.remote_ip
            @review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]
            if @review.update(review_params)

              render_serialized_payload {serialize_resource(@review)}
            else
              render_error_payload(product_question.errors)
            end
          end

          def destroy
            # TODO: fix permission
            # authorize! :destroy, @review
            if @review.destroy
              render_serialized_payload { serialize_resource(@review) }
            else
              render_error_payload('Something went wrong')
            end
          end

          private

          def create_service
            Spree::Api::Dependencies.storefront_account_create_address_service.constantize
          end

          def scope
            Spree::Review
          end

          def resource
            scope.find(params[:id])
          end

          def collection_serializer
            Spree::V2::Storefront::ReviewSerializer
          end

          def resource_serializer
            Spree::V2::Storefront::ReviewSerializer
          end

          def paginated_collection
            collection_paginator.new(collection, params).call
          end

          def collection
            return Spree::Review.approved.where(product: @product) if @product

            # for security reason only return current user's product questions
            Spree::Review.where(user_id: spree_current_user) if params[:user_id]
          end

          def load_product
            @product = Spree::Product.friendly.where(id: params[:product_id]).first
          end

          def load_review
            @review = Spree::Review.find_by(id: params[:id])
          end

          def permitted_review_attributes
            [:rating, :title, :review, :name, :show_identifier]
          end

          def review_params
            params.require(:review).permit(permitted_review_attributes)
          end

          def render_result(review)
            if review.save
              render_serialized_payload {serialize_resource(review)}
            else
              # TODO handle error from service
              render_error_payload(review.errors)
            end
            # if result.success?
            #   render_serialized_payload { serialize_resource(result.value) }
            # else
            #   render_error_payload(result.error)
            # end
          end

        end
      end
    end
  end
end
