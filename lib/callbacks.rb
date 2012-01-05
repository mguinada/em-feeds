# == Callbacks
#
# Sets up callback infrastructure
#
module Callbacks
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    #
    # Macro to create callback infrastructure
    #
    # === Example
    # class MotionSensor
    #   callbacks :on_detection, :on_power_cut
    #
    #   def trigger_motion_detection(sensor_id)
    #     on_detection_callbacks.each { |callback| callback.call(sensor_id) }
    #   end
    #
    #   def trigger_power_cut_warning(sensor_id)
    #     on_power_cut_callbacks.each { |callback| callback.call(sensor_id) }
    #   end
    #
    #   def enable
    #     trigger_motion_detection("#6")
    #     trigger_power_cut_warning("#6")
    #   end
    # end
    #
    # class ClientCode
    #   def initialize
    #     @sensor = MotionSensor.new
    #
    #     @sensor.on_detection do |sensor_id|
    #       puts "Movement detected on sensor #{sensor_id}"
    #     end
    #
    #     @sensor.on_power_cut do
    #       puts "Power cut signal received"
    #     end
    #
    #     @sensor.on_power_cut do |sensor_id|
    #       puts "POWER CUT ON SENSOR #{sensor_id}"
    #     end
    #     @sensor.enable
    #   end
    # end
    #
    # ClientCode.new
    #
    #

    def callbacks(*args)
      #TODO: Check possible method existence before dynamic creation
      args = [ :on_success, :on_error ] if args.empty?
      args.each do |callback_name|
        instance_var_name = "@_#{callback_name.to_s}_callbacks".to_sym
        callback_accessor_name = "#{callback_name.to_s}_callbacks".to_sym

        #defines the accessor for the callbacks array
        define_method callback_accessor_name do
          instance_variable_get(instance_var_name)
        end

        #defines the callback setter
        define_method callback_name.to_sym do |&block|
          if instance_variable_get(instance_var_name).nil? #lazy creation
            instance_variable_set(instance_var_name, [])
          end
          instance_variable_get(instance_var_name).send(:<<, block)
        end
      end
    end
  end
end

Object.send :include, Callbacks