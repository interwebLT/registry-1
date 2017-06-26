module Billing
  class Price < ActiveRecord::Base
    include Concerns::Billing::Price::Expirable

    self.auto_html5_validation = false

    belongs_to :zone, class_name: 'DNS::Zone', required: true
    has_many :account_activities

    validates :price, :valid_from, :operation_category, :duration, presence: true
    validates :operation_category, inclusion: { in: Proc.new { |price| price.class.operation_categories } }
    validates :duration, inclusion: { in: Proc.new { |price| price.class.durations } }

    alias_attribute :effect_time, :valid_from
    alias_attribute :expire_time, :valid_to
    monetize :price_cents, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }

    attr_accessor :effect_time_date
    attr_accessor :effect_time_time
    attr_accessor :expire_time_date
    attr_accessor :expire_time_time

    def self.operation_categories
      %w[create renew]
    end

    def self.durations
      [
        '3 mons',
        '6 mons',
        '9 mons',
        '1 year',
        '2 years',
        '3 years',
        '4 years',
        '5 years',
        '6 years',
        '7 years',
        '8 years',
        '9 years',
        '10 years',
      ]
    end

    def self.statuses
      %w[upcoming effective expired]
    end

    def self.upcoming
      where("#{attribute_alias(:effect_time)} > ?", Time.zone.now)
    end

    def self.effective
      condition = "#{attribute_alias(:effect_time)} <= :now " \
      " AND (#{attribute_alias(:expire_time)} >= :now" \
      " OR #{attribute_alias(:expire_time)} IS NULL)"
      where(condition, now: Time.zone.now)
    end

    def self.price_for(zone, operation_category, duration)
      lists = effective.where(zone: zone, operation_category: operation_category, duration: duration)
      return lists.first if lists.count == 1
      lists.order(valid_from: :desc).first
    end

    def name
      "#{operation_category} #{zone_name}"
    end

    def zone_name
      zone.origin
    end

    def to_partial_path
      'price'
    end
  end
end
