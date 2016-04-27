module Spree
  module Marketing
    class MostZoneWiseOrdersList < List

      include Spree::Marketing::ActsAsMultiList

      # Constants
      ENTITY_KEY = 'state_id'
      TIME_FRAME = 1.month
      MOST_ZONE_WISE_ORDERS_COUNT = 5

      attr_accessor :state_id

      def user_ids
        # FIXME: There are some countries which do not have states, we are leaving those cases for now.
        Spree::Order.joins(ship_address: :state)
                    .of_registered_users
                    .where("spree_states.id = ?", @state_id)
                    .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time)
                    .group(:user_id)
                    .order("COUNT(spree_orders.id) DESC")
                    .pluck(:user_id)
      end

      def self.state_name state_id
        Spree::State.find_by(id: state_id).name.downcase.gsub(" ", "_")
      end
      private_class_method :state_name

      def self.name_text state_id
        humanized_name + "_" + state_name(state_id)
      end
      private_class_method :name_text

      def self.data
        Spree::Order.joins(ship_address: :state)
          .group("spree_states.id")
          .order("COUNT(spree_orders.id) DESC")
          .limit(MOST_ZONE_WISE_ORDERS_COUNT)
          .pluck(:state_id)
      end
      private_class_method :data
    end
  end
end