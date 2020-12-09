module Spree::ProductsControllerDecorator
  def self.prepended(base)
    base.helper Spree::ReviewsHelper
  end

  reviews_fields = [:avg_rating, :reviews_count]
  reviews_fields.each { |attrib| Spree::PermittedAttributes.product_attributes << attrib }

  Spree::Api::ApiHelpers.class_eval do
    reviews_fields.each { |attrib| class_variable_set(:@@product_attributes, class_variable_get(:@@product_attributes).push(attrib)) }
  end
end

# TODO find better way to handle (uninitialized constant Spree::ProductsController) instead of rescuing with nil
# ::Spree::ProductsController.prepend(Spree::ProductsControllerDecorator) rescue nil
