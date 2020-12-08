module Spree
  module V2
    module Storefront
      module ProductSerializerDecorator
        def self.prepended(base)
          base.attributes :stars, :reviews_count
        end
      end
    end
  end
end

::Spree::V2::Storefront::ProductSerializer.prepend ::Spree::V2::Storefront::ProductSerializerDecorator if ::Spree::V2::Storefront::ProductSerializer.included_modules.exclude?(::Spree::V2::Storefront::ProductSerializerDecorator)
