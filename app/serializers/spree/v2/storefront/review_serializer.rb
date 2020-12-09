module Spree
  module V2
    module Storefront
      class ReviewSerializer < BaseSerializer
        set_type :review

        attributes :title, :review, :rating, :name, :show_identifier, :created_at

        has_one :user
        has_one :product
      end
    end
  end
end
