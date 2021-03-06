require 'active_record'

module MerbAdmin
  class AbstractModel
    module ActiverecordSupport
      def get(id)
        model.find_by_id(id).extend(InstanceMethods)
      rescue ActiveRecord::RecordNotFound
        nil
      end

      def count(options = {})
        model.count(options.reject{|key, value| [:sort, :sort_reverse].include?(key)})
      end

      def first(options = {})
        model.first(merge_order(options)).extend(InstanceMethods)
      end

      def last(options = {})
        model.last(merge_order(options)).extend(InstanceMethods)
      end

      def all(options = {})
        model.all(merge_order(options))
      end

      def paginated(options = {})
        page = options.delete(:page) || 1
        per_page = options.delete(:per_page) || MerbAdmin[:per_page]

        page_count = (count(options).to_f / per_page).ceil

        options.merge!({
          :limit => per_page,
          :offset => (page - 1) * per_page
        })

        [page_count, all(options)]
      end

      def create(params = {})
        model.create(params).extend(InstanceMethods)
      end

      def new(params = {})
        model.new(params).extend(InstanceMethods)
      end

      def destroy_all!
        model.all.each do |object|
          object.destroy
        end
      end

      def has_many_associations
        associations.select do |association|
          association[:type] == :has_many
        end
      end

      def has_one_associations
        associations.select do |association|
          association[:type] == :has_one
        end
      end

      def belongs_to_associations
        associations.select do |association|
          association[:type] == :belongs_to
        end
      end

      def associations
        model.reflect_on_all_associations.map do |association|
          {
            :name => association.name,
            :pretty_name => association.name.to_s.gsub('_', ' ').capitalize,
            :type => association.macro,
            :parent_model => association_parent_model_lookup(association),
            :parent_key => association_parent_key_lookup(association),
            :child_model => association_child_model_lookup(association),
            :child_key => association_child_key_lookup(association),
          }
        end
      end

      def properties
        model.columns.map do |property|
          {
            :name => property.name.to_sym,
            :pretty_name => property.human_name,
            :type => property.type,
            :length => property.limit,
            :nullable? => property.null,
            :serial? => property.primary,
          }
        end
      end

      private

      def merge_order(options)
        @sort ||= options.delete(:sort) || "id"
        @sort_order ||= options.delete(:sort_reverse) ? "desc" : "asc"
        options.merge(:order => ["#{@sort} #{@sort_order}"])
      end

      def association_parent_model_lookup(association)
        case association.macro
        when :belongs_to
          association.klass
        when :has_one, :has_many
          association.active_record
        else
          raise "Unknown association type"
        end
      end

      def association_parent_key_lookup(association)
        [:id]
      end

      def association_child_model_lookup(association)
        case association.macro
        when :belongs_to
          association.active_record
        when :has_one, :has_many
          association.klass
        else
          raise "Unknown association type"
        end
      end

      def association_child_key_lookup(association)
        case association.macro
        when :belongs_to
          ["#{association.class_name.snake_case}_id".to_sym]
        when :has_one, :has_many
          [association.primary_key_name.to_sym]
        else
          raise "Unknown association type"
        end
      end

      module InstanceMethods
      end

    end
  end
end
