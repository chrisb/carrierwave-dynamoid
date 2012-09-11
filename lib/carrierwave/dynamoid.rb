# encoding: utf-8

require 'dynamoid'
require 'carrierwave/validations/active_model'

module CarrierWave
  module Dynamoid
    include CarrierWave::Mount

    ##
    # See +CarrierWave::Mount#mount_uploader+ for documentation
    #
    def mount_uploader(column, uploader=nil, options={}, &block)
      field options[:mount_on] || column

      super

      alias_method :read_uploader, :read_attribute
      alias_method :write_uploader, :write_attribute
      public :read_uploader
      public :write_uploader

      include CarrierWave::Validations::ActiveModel

      validates_integrity_of column if uploader_option(column.to_sym, :validate_integrity)
      validates_processing_of column if uploader_option(column.to_sym, :validate_processing)
      #validates_download_of column if uploader_option(column.to_sym, :validate_download)

      after_save :"store_#{column}!"
      before_save :"write_#{column}_identifier"
      after_destroy :"remove_#{column}!"
      before_update :"store_previous_model_for_#{column}"
      after_save :"remove_previously_stored_#{column}"

      class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{column}=(new_file)
          column = _mounter(:#{column}).serialization_column
          send(:"\#{column}_will_change!")
          super
        end

        def #{column}_changed?
          changed_attributes.has_key?("#{column}")
        end

        def find_previous_model_for_#{column}
          if self.embedded?
            ancestors       = [[ self.metadata.key, self._parent ]].tap { |x| x.unshift([ x.first.last.metadata.key, x.first.last._parent ]) while x.first.last.embedded? }
            first_parent = ancestors.first.last
            reloaded_parent = first_parent.class.unscoped.find(first_parent.to_key.first)
            association = ancestors.inject(reloaded_parent) { |parent,(key,ancestor)| (parent.is_a?(Array) ? parent.find(ancestor.to_key.first) : parent).send(key) }
            association.is_a?(Array) ? association.find(to_key.first) : association
          else
            self.class.unscoped.find(to_key.first)
          end
        end

        def remote_#{column}_url=(url)
          column = _mounter(:#{column}).serialization_column
          send(:"\#{column}_will_change!")
          super
        end

        def remove_#{column}!
          super
          _mounter(:#{column}).remove = true
          _mounter(:#{column}).write_identifier
        end

        def serializable_hash(options=nil)
          hash = {}

          except = options && options[:except] && Array.wrap(options[:except]).map(&:to_s)
          only   = options && options[:only]   && Array.wrap(options[:only]).map(&:to_s)

          self.class.uploaders.each do |column, uploader|
            if (!only && !except) || (only && only.include?(column.to_s)) || (except && !except.include?(column.to_s))
              hash[column.to_s] = _mounter(column).uploader.serializable_hash
            end
          end
          super(options).merge(hash)
        end
      RUBY

    end

  end # Dynamoid
end # CarrierWave

Dynamoid::Document::ClassMethods.send(:include, CarrierWave::Dynamoid)
#Dynamoid::Document.extend CarrierWave::Dynamoid
