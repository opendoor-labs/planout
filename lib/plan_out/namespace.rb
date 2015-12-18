require 'logger'
require 'json'

module PlanOut
  class Namespace
    def initialize(inputs)
    end

    def add_experiment(name, exp_object, num_segments, inputs)
    end

    def remove_experiment(name)
    end

    def set_auto_exposure_logging(value)
    end

    def in_experiment
    end

    def get(name, default)
    end

    def log_exposure(extras=nil)
    end

    def log_event(event_type, extras=nil)
    end
  end

  class SimpleNamespace < Namespace
    attr_accessor :_primary_unit

    def initialize(inputs)
      @name = self.class.name
      @inputs = inputs
      @num_segments = nil

      @segment_allocations = {}
      @current_experiments = {}

      @_experiment = nil
      @_default_experiment = nil
      @default_experiment_class = PlanOut::DefaultExperiment
      @_in_experiment = false

      setup
      @available_segments = (0...@num_segments).to_a

      setup_experiments
    end

    def setup
    end

    def setup_experiments
    end

    def primary_unit
      @_primary_unit
    end

    def add_experiment(name, exp_object, segments)
      if @available_segments.length < segments
        return false
      end

      if @current_experiments.include?(name)
        return false
      end

      assignment = Assignment.new(name)
      assignment[:sampled_segments] = PlanOut::Sample.new(choices: @available_segments,
                                                        draws: segments,
                                                        unit: @name) 
      assignment[:sampled_segments].each do |segment|
        @segment_allocations[segment] = name
        @available_segments.delete(segment)
      end

      @current_experiments[name] = exp_object
    end

    def remove_experiment(name)
      return unless @current_experiments.key?(name)

      segments_to_free = @segment_allocations.select { |k, v| v == name }.keys

      segments_to_free.each do |segment|
        @segment_allocations.delete(segment)
        @available_segments << segment
      end

      @current_experiments.delete(name)

      true
    end

    def get_segment
      a = Assignment.new(@name)
      units = []
      @primary_unit.map(&:to_sym).each do |unit|
        units << @inputs[unit]
      end
      a[:segment] = PlanOut::RandomInteger.new(min: 0,
                                             max: @num_segments - 1,
                                             unit: units)
      a[:segment]
    end

    def _assign_experiment
      segment = get_segment

      if @segment_allocations.include?(segment)
        experiment_name = @segment_allocations[segment]
        experiment = @current_experiments[experiment_name].new(@inputs)
        experiment.instance_variable_set(:@name, "#{@name}-#{experiment_name}")
        experiment.instance_variable_set(:@_salt, "#{@name}.#{experiment_name}")
        @_experiment = experiment
        @_in_experiment = experiment.instance_variable_get(:@in_experiment)

        _assign_default_experiment if !@_in_experiment
      end
    end

    def _assign_default_experiment
      @_default_experiment = @default_experiment_class.new(@inputs)
    end

    def default_get(name, default=nil)
      _assign_default_experiment if !@_default_experiment

      @_default_experiment.get(name, default)
    end

    def in_experiment
      assign_experiment
      @_in_experiment
    end

    def set_auto_exposure_logging(value)
      assign_experiment
      @_experiment.set_auto_exposure_logging(value)
    end

    def get(name, default=nil)
      assign_experiment

      if @_experiment.nil?
        default_get(name, default) 
      else
        @_experiment.get(name, default_get(name, default))
      end
    end

    def log_exposure(extras=nil)
      assign_experiment

      if !@_experiment.blank?
        @_experiment.log_exposure(extras)
      end
    end

    def log_event(event_type, extras=nil)
      assign_experiment

      if @_experiment.blank?
        @_experiment.log_event(event_type, extras) 
      end
    end

    def assign_experiment
      _assign_experiment if !@_experiment
    end
  end
end
