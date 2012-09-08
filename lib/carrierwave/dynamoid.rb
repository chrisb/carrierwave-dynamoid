# encoding: utf-8

require 'dynamoid'
require 'carrierwave/orm/activerecord'

Dynamoid::Document::ClassMethods.send(:include, CarrierWave::ActiveRecord)
